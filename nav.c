#include <signal.h>
#include <ncurses.h>
#include <time.h>
#include <dirent.h> 
#include <sys/stat.h>
#include <string.h>
#include <limits.h>
#include <stdlib.h>
#include <locale.h>
#include <unistd.h>
#include <wchar.h>
#include <wctype.h>

#define MAX_ENTRY_LENGTH 45
#define KEY_ESCAPE 27

struct entry_array {
    int max_size;
    int max_ptrs_size;
    int entries_size;
    int entry_count;
    char** entry_pointers;
    char* entries;
};

struct entry_ptrs { 
    int max_size;
    int dir_count;
    int file_count;
    char** ptrs;
};

struct entry_array file_array;
struct entry_array dir_array;
struct entry_ptrs found_ptrs; 
struct entry_ptrs all_ptrs; 
char current_path[PATH_MAX];
int current_path_length;
char* user_shell;
int longest_entry = 0; 
WINDOW* win;
int termx;
int termy; 
int winx;
int winy;

void panic(char* errormsg) 
{
    delwin(win);
    endwin();
    printf("%s\n", errormsg);
    exit(EXIT_FAILURE);
}

void init()
{
    user_shell = getenv("SHELL");
    getcwd(current_path, PATH_MAX);
    current_path_length = strlen(current_path);
    
    file_array.entry_count = 0;
    file_array.max_size = 512;
    file_array.max_ptrs_size = 512;
    file_array.entries_size = 0;
    file_array.entries = (char*)malloc(512);
    file_array.entry_pointers = (char**)malloc(512);
    dir_array.entry_count = 0;
    dir_array.max_size = 512;
    dir_array.max_ptrs_size = 512;
    dir_array.entries_size = 0;
    dir_array.entries = (char*)malloc(512);
    dir_array.entry_pointers = (char**)malloc(512);
    found_ptrs.dir_count = 0;
    found_ptrs.file_count= 0;
    found_ptrs.ptrs = malloc(512);
    found_ptrs.max_size = 512;
    all_ptrs.dir_count = 0;
    all_ptrs.file_count= 0;
    all_ptrs.ptrs = malloc(512);
    all_ptrs.max_size = 512;

    if (file_array.entries == NULL ||
        dir_array.entries == NULL ||
        dir_array.entry_pointers == NULL ||
        file_array.entry_pointers == NULL ||
        found_ptrs.ptrs == NULL ||
        all_ptrs.ptrs == NULL) {

        panic("memory allocation error");
    }
}

int compare_entries(const void* a, const void* b) 
{
    const char* entry_a = *(const char**)a;
    const char* entry_b = *(const char**)b;
    return strcmp(entry_a, entry_b);
}

void extend_entry_array(struct entry_array* arr) 
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
        panic("realloc error");
    }
}

void extend_entry_array_pointers(struct entry_array* arr) 
{
    char** realloced = (char**)realloc(arr->entry_pointers, arr->max_ptrs_size * 2);
    if (realloced) {
        arr->entry_pointers = realloced;
        arr->max_ptrs_size *= 2;
    }
    else {
        panic("realloc error");
    }
}

void extend_ptrs_array(struct entry_ptrs* arr)
{
    char** realloced = (char**)realloc(arr->ptrs, arr->max_size * 2);
    if (realloced) {
        arr->ptrs = realloced;
        arr->max_size *= 2;
    }
    else {
        panic("realloc error");
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

void add_entry(char* entry, struct entry_array* arr) 
{
    int len = strlen(entry);
    if (len > longest_entry && len <= MAX_ENTRY_LENGTH) longest_entry = len;
    while ((arr->entries_size + len + 1) > arr->max_size) {
        extend_entry_array(arr);
    }
    while (arr->entry_count * sizeof(char*) > arr->max_ptrs_size) {
        extend_entry_array_pointers(arr);
    }
    char* array_head = arr->entries + arr->entries_size;
    memcpy(array_head, entry, len);
    array_head[len] = '\0';
    arr->entries_size += len + 1;
    arr->entry_pointers[arr->entry_count] = array_head;
    arr->entry_count++;
}

void get_dir_contents(char* dirname) 
{
    DIR *dir;
    struct dirent *ent;
    struct stat filestat;

    dir = opendir(dirname);
    if (dir == NULL) {
        panic("opendir() error");
    }

    // ent = readdir(dir); // the "." directory is omitted

    dir_array.entry_count = 0;
    file_array.entry_count = 0;
    found_ptrs.file_count = 0;
    found_ptrs.dir_count = 0;
    longest_entry = 0;
    
    while ((ent = readdir(dir)) != NULL) {
        if (!strcmp(ent->d_name, "."))
            continue;
        if (ent->d_type == DT_DIR) {
            add_entry(ent->d_name, &dir_array);
        } 
        else {
            add_entry(ent->d_name, &file_array);
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

WINDOW* make_window() 
{
    getmaxyx(stdscr, termy, termx);
    winx = termx * 0.8;
    winy = termy * 0.9;
    int startx = (termx - winx) / 2;
    int starty = (termy - winy) / 2;
    WINDOW* window = newwin(winy, winx, starty, startx);
    return window;
}

int count_utf8_code_points(char* s) {
    int count = 0;
    while (*s) {
        count += (*s++ & 0xC0) != 0x80;
    }
    return count;
}

void draw_entries(uint32_t selected_index, struct entry_ptrs* ptrs)
{
    int column_count = winx / longest_entry;
    if (column_count <= 0) 
        column_count = 1;
    int entries_per_page = (column_count * (winy - 3));
    int current_page = selected_index / entries_per_page;
    int start_index = current_page * entries_per_page;
    int end_index;
    if (ptrs->dir_count + ptrs->file_count - start_index < entries_per_page) 
        end_index = ptrs->dir_count + ptrs->file_count; 
    else 
        end_index = start_index + entries_per_page; 

    int row = 0;
    int x = 0;
    int y = 3;
    for (int i = start_index; i < end_index; i++) {
        int color = 0;
        if (selected_index == i) 
            color = 1;
        else if (i < ptrs->dir_count) 
            color = 2;

        wattron(win, COLOR_PAIR(color));
        mvwprintw(win, y, x, "%.*s", longest_entry, ptrs->ptrs[i]);
        int len = count_utf8_code_points(ptrs->ptrs[i]);
        if (len > MAX_ENTRY_LENGTH) 
            len = MAX_ENTRY_LENGTH;
        if (i < ptrs->dir_count) 
            mvwprintw(win, y, x + len, "/");
        wattroff(win, COLOR_PAIR(color));

        x += longest_entry + 2;
        row++;
        if (row > column_count - 1) {
            y++;
            x = 0;
            row = 0;
        }
    }
}

void search_entries(wchar_t* searchstring)
{
    static char multi_byte[NAME_MAX];
    int written = wcstombs(multi_byte, searchstring, NAME_MAX);
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
        panic("chdir error");
    }
}

void entry_search_loop() 
{
    wchar_t c = 0;
    wchar_t searchstring[NAME_MAX] = {};
    uint32_t searchstringindex = 0;
    uint32_t selected_index = 1;
    struct entry_ptrs* current_ptrs = &all_ptrs;
    
    draw_entries(1, current_ptrs);
    wmove(win, 0, 0);
    refresh();
    wrefresh(win);

    while (true) {
        clock_t start_time = clock();
        get_wch((wint_t*)&c);

        if (c == KEY_ESCAPE) {
            delwin(win);
            endwin();
            // system(user_shell);
            exit(EXIT_SUCCESS);
        }
        else if (c == KEY_RESIZE) {
            getmaxyx(stdscr, termy, termx);
            winx = termx * 0.8;
            winy = termy * 0.9;
            wresize(win, winy, winx);
        }
        else if (c == L'\n') {
            if (selected_index < current_ptrs->dir_count) {
                change_directory(current_ptrs->ptrs[selected_index]);
                searchstringindex = 0;
                searchstring[0] = '\0';
            }
            else {
                // unfinished: open with text editor
            }
        }
        else if (c == L'\t') {
            if (selected_index != current_ptrs->dir_count + current_ptrs->file_count - 1)
                selected_index++;
            else
                selected_index = 0;
        }
        else if (c == KEY_BTAB) {
            if (selected_index != 0) 
                selected_index--;
            else
                selected_index = current_ptrs->dir_count + current_ptrs->file_count - 1;
        }
        else if (c == KEY_BACKSPACE || c == 127 || c == '\b') {
            if (searchstringindex > 0) {
                searchstringindex--;
                searchstring[searchstringindex] = '\0';
                selected_index = 0;
            }
        }
        else {
            searchstring[searchstringindex] = c;
            searchstring[searchstringindex + 1] = '\0';
            searchstringindex++;
            selected_index = 0;
        }

        werase(win);
        mvwaddwstr(win, 0, 0, searchstring);

        if (searchstringindex != 0) {
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
        
        wmove(win, 0, searchstringindex);
        refresh();
        wrefresh(win);

        clock_t end_time = clock();
        double elapsed_time = ((double) (end_time - start_time)) / CLOCKS_PER_SEC;
        mvwprintw(win, 2, 0, "Time elapsed: %f milliseconds", elapsed_time * 1000);
        wmove(win, 0, searchstringindex);
        wrefresh(win);
    }
}

void sigint_handler(int sig)
{
    panic("Ctrl + C pressed");
}

int main() 
{
    clock_t start_time = clock();

    signal(SIGINT, sigint_handler);

    setlocale(LC_ALL, "");

    initscr();
    cbreak();
    noecho();
    keypad(stdscr, TRUE);
    start_color();
    use_default_colors();
    init_color(COLOR_BLUE, 500, 700, 999);
    init_pair(1, COLOR_BLACK, COLOR_WHITE);
    init_pair(2, COLOR_BLUE, -1);

    win = make_window();   
    init();
    // get_dir_contents(".");
    get_dir_contents("/usr/share/man/man3");
    // get_dir_contents("/home/nl/utftest");
    // get_dir_contents("/home/nl/");
    // get_dir_contents(current_path);
    // get_dir_contents("/");

    // maketestentries();
    
    wmove(win, 0, 0);

    clock_t end_time = clock();
    double elapsed_time = ((double) (end_time - start_time)) / CLOCKS_PER_SEC;
    mvwprintw(win, 2, 0, "Time elapsed: %f milliseconds", elapsed_time * 1000);

    entry_search_loop();

    // getch();
    delwin(win);
    endwin();


    return 0;
}
