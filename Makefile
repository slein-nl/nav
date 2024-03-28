CC = clang
CFLAGS = -DNCURSES_WIDECHAR=1
LDFLAGS = -lncursesw

ifeq ($(TIME),1)
CFLAGS += -DTIME_MEASUREMENT
endif

TARGET = nav
BUILD_DIR = ./build
SRC_FILES = $(wildcard *.c)
OBJ_FILES = $(SRC_FILES:%.c=$(BUILD_DIR)/%.o)

all: build_dir release debug

release: CFLAGS += -O3
release: $(BUILD_DIR)/$(TARGET)

debug: CFLAGS += -ggdb3
debug: $(BUILD_DIR)/$(TARGET)_debug

clean:
	@rm -rf $(BUILD_DIR)/*

build_dir:
	@mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/$(TARGET): $(OBJ_FILES)
	$(CC) $(CFLAGS) $(LDFLAGS) $^ -o $@

$(BUILD_DIR)/$(TARGET)_debug: $(OBJ_FILES)
	$(CC) $(CFLAGS) -g $(LDFLAGS) $^ -o $@

$(BUILD_DIR)/%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@
