CC = clang
CFLAGS = -DNCURSES_WIDECHAR=1
LDFLAGS = -lncursesw

TARGET = nav

SRC_FILES = $(wildcard *.c)

all: release debug

release: CFLAGS += -O3
release: $(TARGET)

debug: CFLAGS += -ggdb3
debug: $(TARGET)_debug

$(TARGET): $(OBJ_FILES)
	$(CC) $(CFLAGS) $(LDFLAGS) $^ -o $@

$(TARGET)_debug: $(OBJ_FILES)
	$(CC) $(CFLAGS) -g $(LDFLAGS) $^ -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@
