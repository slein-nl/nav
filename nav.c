#include <linux/limits.h>
#include <signal.h>
#include <ncurses.h>
#include <stdio.h>
#include <strings.h>
#include <time.h>
#include <dirent.h> 
#include <sys/stat.h>
#include <string.h>
#include <wait.h>
#include <limits.h>
#include <stdlib.h>
#include <locale.h>
#include <unistd.h>
#include <wchar.h>
#include <wctype.h>
#include <sys/syscall.h>
#include <fcntl.h>

#ifdef TIME_MEASUREMENT
#define TIME_START(start_time) clock_t start_time = clock()
#define TIME_END(win, start_time) do { \
    clock_t end_time = clock(); \
    double elapsed_time = ((double) (end_time - start_time)) / CLOCKS_PER_SEC; \
    snprintf(user_msg, 256, "Time elapsed: %f milliseconds", elapsed_time * 1000); \
} while(0)
#else
#define TIME_START(start_time)
#define TIME_END(win, start_time)
#endif

#define MAX_ENTRY_LENGTH 45
#define INTER_COLUMN_SPACING 2
#define KEY_ESCAPE 27
#define KEY_CTRL_U 0x15
#define KEY_CTRL_D 0x04
#define KEY_TAB 0x09

typedef struct {
    int max_size;
    int max_ptrs_size;
    int entries_size;
    int entry_count;
    char** entry_pointers;
    char* entries;
} entry_array;

typedef struct { 
    int max_size;
    int dir_count;
    int file_count;
    char** ptrs;
} entry_ptrs;

typedef struct {
    int size;
    int max_size;
    char* buffer;
} file_preview_buffer;

entry_array file_array = {
    .max_size = 512,
    .max_ptrs_size = 512,
    .entry_count = 0,
    .entries_size = 0,
};
entry_array dir_array = {
    .max_size = 512,
    .max_ptrs_size = 512,
    .entry_count = 0,
    .entries_size = 0,
};
entry_array preview_file_array = {
    .max_size = 512,
    .max_ptrs_size = 512,
    .entry_count = 0,
    .entries_size = 0,
};
entry_array preview_dir_array = {
    .max_size = 512,
    .max_ptrs_size = 512,
    .entry_count = 0,
    .entries_size = 0,
};

entry_ptrs found_ptrs = {
    .max_size = 512,
    .dir_count = 0,
    .file_count = 0,
};
entry_ptrs all_ptrs = {
    .max_size = 512,
    .dir_count = 0,
    .file_count = 0,
}; 

char user_msg[256];
char current_path[PATH_MAX];
char tmp_file_path[PATH_MAX];
int entries_per_page;
char* user_shell;
char* user_editor;
int longest_entry; 
WINDOW* win;
WINDOW* preview_win;
int termx;
int termy; 
int winx;
int winy;
int preview_winx;
int preview_winy;
int preview_longest_entry;

void panic(char* error_msg) 
{
    endwin();
    printf("%s\n", error_msg);
    exit(EXIT_FAILURE);
}

inline void error(char* error_msg) 
{
    snprintf(user_msg, 256, "%s", error_msg);
}

void init()
{
    user_shell = getenv("SHELL");
    user_editor = getenv("EDITOR");

    file_array.entries = (char*)malloc(512);
    file_array.entry_pointers = (char**)malloc(512);
    dir_array.entries = (char*)malloc(512);
    dir_array.entry_pointers = (char**)malloc(512);
    preview_file_array.entries = (char*)malloc(512);
    preview_file_array.entry_pointers = (char**)malloc(512);
    preview_dir_array.entries = (char*)malloc(512);
    preview_dir_array.entry_pointers = (char**)malloc(512);
    found_ptrs.ptrs = malloc(512);
    all_ptrs.ptrs = malloc(512);

    if (file_array.entries                == NULL ||
        dir_array.entries                 == NULL ||
        dir_array.entry_pointers          == NULL ||
        file_array.entry_pointers         == NULL ||
        preview_file_array.entries        == NULL ||
        preview_file_array.entry_pointers == NULL ||
        preview_dir_array.entries         == NULL ||
        preview_dir_array.entry_pointers  == NULL ||
        found_ptrs.ptrs                   == NULL ||
        all_ptrs.ptrs                     == NULL) {

        panic("Error: Error when allocating memory");
    }
}

int compare_entries(const void* a, const void* b) 
{
    const char* entry_a = *(const char**)a;
    const char* entry_b = *(const char**)b;
    return strcasecmp(entry_a, entry_b);
}

int count_utf8_code_points(char* s) {
    int count = 0;
    while (*s) {
        // count if byte not continuation byte
        count += (*s & 0xC0) != 0x80; 
        s++;
    }
    return count;
}

void extend_entry_array(entry_array* arr) 
{
    char* realloced = (char*)realloc(arr->entries, arr->max_size * 2);
    if (realloced) {
        if (realloced != arr->entries) {
            // update entry pointers to point to the new locations
            for (int i = 0; i < arr->entry_count; i++) {
                arr->entry_pointers[i] = realloced + (arr->entry_pointers[i] - arr->entries);
            }
            arr->entries = realloced;
        }
        arr->max_size *= 2;
    }
    else {
        panic("Error: Realloc error when loading directory entries");
    }
}

void extend_entry_array_pointers(entry_array* arr) 
{
    char** realloced = (char**)realloc(arr->entry_pointers, arr->max_ptrs_size * 2);
    if (realloced) {
        arr->entry_pointers = realloced;
        arr->max_ptrs_size *= 2;
    }
    else {
        panic("Error: Realloc error when loading directory entries");
    }
}

void extend_ptrs_array(entry_ptrs* arr)
{
    char** realloced = (char**)realloc(arr->ptrs, arr->max_size * 2);
    if (realloced) {
        arr->ptrs = realloced;
        arr->max_size *= 2;
    }
    else {
        panic("Error: Realloc error when loading directory entries");
    }
}

void add_found_ptr(char* ptr)
{
    int current_array_size = sizeof(char*) * (found_ptrs.dir_count + found_ptrs.file_count);
    if (current_array_size + sizeof(char*) > found_ptrs.max_size) {
        extend_ptrs_array(&found_ptrs);
    }
    char** array_head = (char**)((char*)found_ptrs.ptrs + current_array_size);
    *array_head = ptr;
}

void add_entry(char* entry, entry_array* arr, int* longest_entry) 
{
    int len = count_utf8_code_points(entry);
    int size = strlen(entry);
    if (len > *longest_entry && len <= MAX_ENTRY_LENGTH) 
        *longest_entry = len;
    while ((arr->entries_size + len + 1) > arr->max_size) {
        extend_entry_array(arr);
    }
    while (arr->entry_count * sizeof(char*) > arr->max_ptrs_size) {
        extend_entry_array_pointers(arr);
    }
    char* array_head = arr->entries + arr->entries_size;
    memcpy(array_head, entry, size);
    array_head[size] = '\0';
    arr->entries_size += size + 1;
    arr->entry_pointers[arr->entry_count] = array_head;
    arr->entry_count++;
}

void get_dir_contents(char* dirname) 
{
    DIR *dir;
    struct dirent *ent;
    struct stat stat_buffer;

    dir = opendir(dirname);
    if (dir == NULL) 
        panic("opendir() error");

    dir_array.entry_count = 0;
    file_array.entry_count = 0;
    found_ptrs.file_count = 0;
    found_ptrs.dir_count = 0;
    longest_entry = 0;
    
    while ((ent = readdir(dir)) != NULL) {
        if (!strcmp(ent->d_name, "."))
            continue;
        if (ent->d_type == DT_DIR) {
            add_entry(ent->d_name, &dir_array, &longest_entry);
        } 
        else if (ent->d_type == DT_LNK) {
            if (stat(ent->d_name, &stat_buffer) != 0) {
                if (lstat(ent->d_name, &stat_buffer) != 0) {
                    panic("lstat error");
                }
            }
            if (S_ISDIR(stat_buffer.st_mode)) {
                add_entry(ent->d_name, &dir_array, &longest_entry);
            }
            else {
                add_entry(ent->d_name, &file_array, &longest_entry);
            }
        } 
        else {
            add_entry(ent->d_name, &file_array, &longest_entry);
        }
    }

    qsort(dir_array.entry_pointers, dir_array.entry_count, sizeof(char*), compare_entries);
    qsort(file_array.entry_pointers, file_array.entry_count, sizeof(char*), compare_entries);
    
    uint64_t all_size = (file_array.entry_count + dir_array.entry_count) * sizeof(char**);
    if (all_ptrs.max_size < all_size) {
        char** realloced = realloc(all_ptrs.ptrs, all_size);
        if (realloced) {
            all_ptrs.ptrs = realloced;
        }
        all_ptrs.max_size = all_size;
    }
    memcpy(all_ptrs.ptrs, dir_array.entry_pointers, dir_array.entry_count * sizeof(char**));
    memcpy(all_ptrs.ptrs + dir_array.entry_count, file_array.entry_pointers, file_array.entry_count * sizeof(char*));
    all_ptrs.file_count = file_array.entry_count;
    all_ptrs.dir_count = dir_array.entry_count;
}

void make_windows() 
{
    float vertical_margin_factor = 0.09;
    getmaxyx(stdscr, termy, termx);
    if (termy > 20) {
        winx = termx * 0.8;
        winy = termy * 0.60;
        preview_winx = termx * 0.8;
        preview_winy = (winy + (termy * vertical_margin_factor)) - (termy * vertical_margin_factor);
        int preview_startx = (termx - winx) / 2;
        int preview_starty = winy + (termy * vertical_margin_factor) + 1;
        preview_win = newwin(preview_winy, preview_winx, preview_starty, preview_startx);
    }
    else {
        winx = termx * 0.8;
        winy = termy * 0.9;
        delwin(preview_win);
        preview_win = NULL;
    }
    int startx = (termx - winx) / 2;
    int starty = termy * vertical_margin_factor;
    win = newwin(winy, winx, starty, startx);
}

void open_editor(char* path) {
    if (!user_editor) {
        error("Error: $EDITOR undefined in environment");
        return;
    }

    // save & disable sighandlers during fork time so they dont interfere with editor
    struct sigaction empty_sigact;
    memset(&empty_sigact, 0, sizeof(struct sigaction));
    struct sigaction sigwinch;
    struct sigaction sigint;
    sigaction(SIGWINCH, &empty_sigact, &sigwinch);
    sigaction(SIGINT, &empty_sigact, &sigint);

    int status;
    int pid = vfork();
    if (pid > 0) {
        waitpid(pid, &status, 0);
        sigaction(SIGWINCH, &sigwinch, NULL);
        sigaction(SIGINT, &sigint, NULL);
    }
    else if (pid == 0) {
        char *args[] = {user_editor, path, NULL};
        endwin();
        execvp(args[0], args);
    }
    else {
        panic("Error: Fork error when opening editor");
    }
}

void open_shell() {
    if (!user_shell) {
        error("Error: $SHELL undefined in environment");
        return;
    }

    // save & disable sighandlers during fork time so they dont interfere with shell
    struct sigaction empty_sigact;
    memset(&empty_sigact, 0, sizeof(struct sigaction));
    struct sigaction sigwinch;
    struct sigaction sigint;
    sigaction(SIGWINCH, &empty_sigact, &sigwinch);
    sigaction(SIGINT, &empty_sigact, &sigint);

    int status;
    int pid = vfork();
    if (pid > 0) {
        waitpid(pid, &status, 0);
        sigaction(SIGWINCH, &sigwinch, NULL);
        sigaction(SIGINT, &sigint, NULL);
    }
    else if (pid == 0) {
        char *args[] = {user_shell, NULL};
        endwin();
        execvp(args[0], args);
    }
    else {
        panic("Error: Fork error when spawning shell");
    }
}

void draw_entries(uint32_t selected_index, entry_ptrs* ptrs)
{
    int column_count = winx / (longest_entry + INTER_COLUMN_SPACING);
    if (column_count <= 0) 
        column_count = 1;
    entries_per_page = (column_count * (winy - 3));
    int current_page = selected_index / entries_per_page;
    int total_page_count = (ptrs->dir_count + ptrs->file_count) / entries_per_page;
    if ((ptrs->dir_count + ptrs->file_count) % entries_per_page != 0)
        total_page_count++;
    if (total_page_count == 0)
        total_page_count = 1;
    char pages[32];
    sprintf(pages, "%d/%d", current_page + 1, total_page_count);
    mvwaddstr(win, 2, winx - strlen(pages), pages);
    int start_index = current_page * entries_per_page;
    int end_index;
    if (ptrs->dir_count + ptrs->file_count - start_index < entries_per_page) 
        end_index = ptrs->dir_count + ptrs->file_count; 
    else 
        end_index = start_index + entries_per_page; 

    int column = 0;
    int x = 0;
    int y = 3;
    for (int i = start_index; i < end_index; i++) {
        static wchar_t wstr[NAME_MAX + 1];
        int len = mbstowcs(wstr, ptrs->ptrs[i], NAME_MAX * sizeof(wchar_t));
        if (len == -1)
            panic("Error: mbstowcs error when converting filename for rendering");
        if (len > longest_entry) {
            len = longest_entry;
            wstr[len - 1] = L'.';
            wstr[len - 2] = L'.';
            wstr[len - 3] = L'.';
        }

        int color = 0;
        if (i < ptrs->dir_count) {
            if (selected_index == i) 
                color = 1;
            else 
                color = 2;
            wstr[len] = L'/';
            wstr[len + 1] = L'\0';
            len++;
        }
        else {
            if (selected_index == i) {
                color = 1;
            }
        }
        wattron(win, COLOR_PAIR(color));
        mvwaddnwstr(win, y, x, wstr, len);
        wattroff(win, COLOR_PAIR(color));

        x += longest_entry + INTER_COLUMN_SPACING;
        column++;
        if (column > column_count - 1) {
            y++;
            x = 0;
            column = 0;
        }
    }
}

void search_entries(wchar_t* searchstring)
{
    static char multi_byte[NAME_MAX * sizeof(wchar_t)];
    int written = wcstombs(multi_byte, searchstring, NAME_MAX * sizeof(wchar_t));
    if (written == -1)
        panic("wcstombs error");

    found_ptrs.file_count = 0;
    found_ptrs.dir_count = 0;
    for (int i = 0; i < dir_array.entry_count; i++) {
        char* found = strcasestr(dir_array.entry_pointers[i], multi_byte);
        if (found) {
            add_found_ptr(dir_array.entry_pointers[i]);
            found_ptrs.dir_count++;
        }
    }
    for (int i = 0; i < file_array.entry_count; i++) {
        char* found = strcasestr(file_array.entry_pointers[i], multi_byte);
        if (found) {
            add_found_ptr(file_array.entry_pointers[i]);
            found_ptrs.file_count++;
        }
    }
}

void change_directory(char* dir)
{
    if (chdir(dir) == 0) {
        getcwd(current_path, PATH_MAX);
        get_dir_contents(current_path);
    }
    else {
        if (access(dir, R_OK) == -1) 
            error("Error: Unable to enter directory due to insufficient permissions");
        else
            panic("Error: chdir() error");

    }
}

void get_preview_dir_contents(char* dirname, int n)
{
    preview_dir_array.entry_count = 0;
    preview_file_array.entry_count = 0;
    preview_longest_entry = 0;
    
    if (access(dirname, R_OK) != 0) {
        add_entry("Insufficient permissions to view directory", &preview_file_array, &preview_longest_entry);        
        return;
    }

    DIR *dir;
    struct dirent *ent;
    struct stat stat_buffer;

    dir = opendir(dirname);
    if (dir == NULL) 
        panic("opendir() error");

    char path[PATH_MAX];
    int len = strlcpy(path, dirname, NAME_MAX);
    path[len] = '/';
    path[len + 1] = '\0';
    int i = 0;
    while ((ent = readdir(dir)) != NULL && i++ < n) {
        if (!strcmp(ent->d_name, "."))
            continue;
        if (!strcmp(ent->d_name, ".."))
            continue;
        if (ent->d_type == DT_DIR) {
            add_entry(ent->d_name, &preview_dir_array, &preview_longest_entry);
        } 
        else if (ent->d_type == DT_LNK) {
            strlcpy(&path[len + 1], ent->d_name, NAME_MAX);
            if (stat(path, &stat_buffer) != 0) {
                if (lstat(path, &stat_buffer) != 0) {
                    panic("lstat error");
                }
            }
            if (S_ISDIR(stat_buffer.st_mode)) {
                add_entry(ent->d_name, &preview_dir_array, &preview_longest_entry);
            }
            else {
                add_entry(ent->d_name, &preview_file_array, &preview_longest_entry);
            }
        } 
        else {
            add_entry(ent->d_name, &preview_file_array, &preview_longest_entry);
        }
    }

    qsort(preview_dir_array.entry_pointers, preview_dir_array.entry_count, sizeof(char*), compare_entries);
    qsort(preview_file_array.entry_pointers, preview_file_array.entry_count, sizeof(char*), compare_entries);
}

void draw_preview_dir()
{
    int column_count = preview_winx / (preview_longest_entry + INTER_COLUMN_SPACING);
    if (column_count <= 0) 
        column_count = 1;

    int total_entries = (preview_winx - 1) * column_count; 
    static wchar_t wstr[NAME_MAX + 1];
    int column = 0;
    int x = 0;
    int y = 1;
    for (int i = 0; i < preview_dir_array.entry_count; i++) {
        int len = mbstowcs(wstr, preview_dir_array.entry_pointers[i], NAME_MAX);
        if (len == -1)
            panic("Error: mbstowcs error when converting filename for rendering");
        if (len > preview_longest_entry) {
            len = preview_longest_entry;
            wstr[len - 1] = L'.';
            wstr[len - 2] = L'.';
            wstr[len - 3] = L'.';
        }
        int color = 2;
        wstr[len] = L'/';
        wstr[len + 1] = L'\0';
        wattron(preview_win, COLOR_PAIR(color));
        mvwaddnwstr(preview_win, y, x, wstr, NAME_MAX);
        wattroff(preview_win, COLOR_PAIR(color));

        x += preview_longest_entry + INTER_COLUMN_SPACING;
        column++;
        if (column > column_count - 1) {
            y++;
            x = 0;
            column = 0;
        }
        if (--total_entries == 0)
            return;
    }
    for (int i = 0; i < preview_file_array.entry_count; i++) {
        int len = mbstowcs(wstr, preview_file_array.entry_pointers[i], NAME_MAX);
        if (len == -1)
            panic("Error: mbstowcs error when converting filename for rendering");
        if (len > preview_longest_entry) {
            len = preview_longest_entry;
            wstr[len - 1] = L'.';
            wstr[len - 2] = L'.';
            wstr[len - 3] = L'.';
        }
        int color = 0;
        wattron(preview_win, COLOR_PAIR(color));
        mvwaddnwstr(preview_win, y, x, wstr, NAME_MAX);
        wattroff(preview_win, COLOR_PAIR(color));

        x += preview_longest_entry + INTER_COLUMN_SPACING;
        column++;
        if (column > column_count - 1) {
            y++;
            x = 0;
            column = 0;
        }
        if (--total_entries == 0)
            return;
    }
}

void draw_text_preview(char* filename, int lines)
{
    FILE* f;
    if (!(f = fopen(filename, "r"))) {
        if (access(filename, R_OK) == -1) 
            mvwaddstr(preview_win, 1, 0, "Error: Insufficient permissions to read file");
        else 
            mvwaddstr(preview_win, 1, 0, "Error: unable to read file");
        return;
    }

    char read_buffer[preview_winx + 1];
    wchar_t write_buffer[preview_winx + 1];
    int written_lines = 0;
    bool incomplete_line = false;
    while (fgets(read_buffer, preview_winx + 1, f) != NULL && written_lines != lines) {
        // if line is incomplete, discard until next line
        if (strchr(read_buffer, '\n') == NULL && !feof(f)) {
            if (incomplete_line)
                continue;
            incomplete_line = true;
        }
        else {
            if (incomplete_line) {
                incomplete_line = false;
                continue;
            }
        }
        
        mbstowcs(write_buffer, read_buffer, preview_winx);
        mvwaddnwstr(preview_win, written_lines + 1, 0, write_buffer, preview_winx);
        written_lines++;
    }

    fclose(f);
}

void entry_search_loop() 
{
    wchar_t c = KEY_BACKSPACE; 
    wchar_t searchstring[NAME_MAX] = {};
    uint32_t cursor_index = 0;
    uint32_t end_index = 0;
    uint32_t selected_index = 1;
    entry_ptrs* current_ptrs = &all_ptrs;
    
    get_dir_contents(current_path);

    while (true) {
        TIME_START(start_time);
        
        switch (c) {
            case KEY_ESCAPE:
                endwin();
                if (tmp_file_path[0] == '\0') {
                    open_shell();
                } 
                else {
                    delwin(win);
                    FILE* f = fopen(tmp_file_path, "w");
                    if (f == NULL)
                        panic("fopen error");
                    if (!fprintf(f, "%s", current_path))
                        panic("fprint error");
                    fclose(f);
                    exit(EXIT_SUCCESS);
                }
                break;

            case KEY_RESIZE:
                clear();
                delwin(win);
                delwin(preview_win);
                refresh();
                make_windows();
                wrefresh(win);
                break;

            case KEY_UP:
                change_directory("..");
                break;

            case KEY_LEFT:
                if (cursor_index > 0) 
                    cursor_index--;
                break;

            case KEY_RIGHT:
                if (cursor_index < end_index) 
                    cursor_index++;
                break;

            case KEY_HOME:
                selected_index = 0;
                break;

            case KEY_CTRL_U:
                if (selected_index >= entries_per_page) 
                    selected_index -= entries_per_page;
                else 
                    selected_index = 0;
                break;

            case KEY_CTRL_D:
                if (selected_index + entries_per_page < current_ptrs->dir_count + current_ptrs->file_count) 
                    selected_index += entries_per_page;
                else 
                    selected_index = current_ptrs->dir_count + current_ptrs->file_count - 1;
                break;

            case KEY_END:
                selected_index = current_ptrs->dir_count + current_ptrs->file_count - 1;
                break;

            case L'\n':
            case KEY_DOWN:
                if (selected_index < current_ptrs->dir_count) {
                    change_directory(current_ptrs->ptrs[selected_index]);
                    if (dir_array.entry_count + file_array.entry_count <= selected_index)
                        selected_index = 0;
                    cursor_index = 0;
                    end_index = 0;
                    searchstring[0] = '\0';
                }
                else {
                    open_editor(current_ptrs->ptrs[selected_index]);
                }
                break;

            case KEY_TAB:
                if (selected_index != current_ptrs->dir_count + current_ptrs->file_count - 1)
                    selected_index++;
                else
                    selected_index = 0;
                break;

            case KEY_BTAB:
                if (selected_index != 0) 
                    selected_index--;
                else 
                    selected_index = current_ptrs->dir_count + current_ptrs->file_count - 1;
                break;

            case KEY_BACKSPACE:
            case 127:
            case '\b':
                if (c == ('\b' & 0x1F)) { // ctrl+backspace
                    if (cursor_index > 0) {
                        int prev = searchstring[--cursor_index];
                        int deleted = 1;
                        while ((cursor_index > 0 && searchstring[cursor_index - 1] != ' ')
                            || (cursor_index > 0 && searchstring[cursor_index - 1] == ' ' && prev == ' ')) {
                            prev = searchstring[cursor_index - 1];
                            cursor_index--;
                            deleted++;
                        }
                        memmove(&searchstring[cursor_index], &searchstring[cursor_index + deleted], (end_index - cursor_index - deleted) * sizeof(wchar_t));
                        end_index -= deleted;
                        searchstring[end_index] = '\0';
                    }
                } 
                else {
                    if (cursor_index > 0) {
                        memmove(&searchstring[cursor_index - 1], &searchstring[cursor_index], (end_index - cursor_index) * sizeof(wchar_t));
                        searchstring[--end_index] = '\0';
                        cursor_index--;
                        selected_index = 0;
                    }
                }
                break;

            default:
                if (cursor_index < end_index) 
                    memmove(&searchstring[cursor_index + 1], &searchstring[cursor_index], (end_index - cursor_index) * sizeof(wchar_t));
                searchstring[cursor_index] = c;
                searchstring[end_index + 1] = '\0';
                cursor_index++;
                end_index++;
                selected_index = 0;
                break;
        }

        werase(win);
        mvwaddwstr(win, 0, 0, searchstring);

        if (end_index != 0) {
            current_ptrs = &found_ptrs;
            search_entries(searchstring);
            if (selected_index > found_ptrs.dir_count + found_ptrs.file_count)
                selected_index = 0;
            draw_entries(selected_index, current_ptrs);
        }
        else {
            current_ptrs = &all_ptrs;
            draw_entries(selected_index, current_ptrs);  
        } 
        
        wattron(win, COLOR_PAIR(4));
        mvwaddstr(win, 2, 0, current_path);
        wattroff(win, COLOR_PAIR(4));

        if (preview_win) {
            werase(preview_win);
            wchar_t preview_file[NAME_MAX];
            if (!mbstowcs(preview_file, current_ptrs->ptrs[selected_index], NAME_MAX))
                panic("Error: mbstowcs error when converting file name for preview");
            int color = 3;
            wattron(preview_win, COLOR_PAIR(color));
            mvwaddwstr(preview_win, 0, 0, preview_file);
            wattroff(preview_win, COLOR_PAIR(color));

            if (selected_index < current_ptrs->dir_count) {
                get_preview_dir_contents(current_ptrs->ptrs[selected_index], 100);
                draw_preview_dir();
            }
            else {
                draw_text_preview(current_ptrs->ptrs[selected_index], preview_winy - 1);
            }
        }

        TIME_END(win, start_time);
        mvwaddstr(win, 1, 0, user_msg);
        wmove(win, 0, cursor_index);
        refresh();
        if (preview_win)
            wrefresh(preview_win);
        wrefresh(win);
        user_msg[0] = '\0';
        get_wch((wint_t*)&c);
    }
}

void sigint_handler(int sig)
{
    endwin();
    exit(EXIT_FAILURE);
}

int main(int argc, char *argv[]) 
{
    TIME_START(start_time);

    signal(SIGINT, sigint_handler);

    set_escdelay(0);
    
    setlocale(LC_ALL, "");
    initscr();
    cbreak();
    noecho();
    keypad(stdscr, TRUE);
    start_color();
    use_default_colors();
    init_color(COLOR_BLUE, 236, 568, 936);
    init_color(COLOR_MAGENTA, 856, 448, 856);
    init_color(COLOR_GREEN, 140, 836, 556);
    init_pair(1, COLOR_BLACK, COLOR_WHITE);
    init_pair(2, COLOR_BLUE, -1);
    init_pair(3, COLOR_MAGENTA, -1);
    init_pair(4, COLOR_GREEN, -1);
    init_pair(6, COLOR_MAGENTA, COLOR_WHITE);

    make_windows();   
    init();

    int dir_changed = 0;
    if (argc > 1) {
        for (int i = 1; i < argc; i++) {
            if (argv[i][0] == '-') {
                if (!strncmp(argv[i], "--cd=", 5)) 
                    realpath(argv[i] + 5, tmp_file_path);
            }
            else {
                dir_changed = 1;
                char full_path[PATH_MAX];
                realpath(argv[i], full_path);
                change_directory(argv[i]);
            }
        }
    }
    if (!dir_changed) {
        getcwd(current_path, PATH_MAX);
    }
    
    wmove(win, 0, 0);

    TIME_END(win, start_time);

    entry_search_loop();

    delwin(win);
    endwin();

    return 0;
}
