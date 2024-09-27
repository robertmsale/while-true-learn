#include <stdio.h>
#include <string.h>
#define BUFFER_SIZE 2097152
#define WORD_SIZE 256

char buf_stdin[BUFFER_SIZE] = {0};
char buf_words[BUFFER_SIZE] = {0};
unsigned long word_count = 0;

void swap(char* left, char* right);
void swap(char* left, char* right) {
    char* temp[WORD_SIZE] = {0};
    memcpy(temp, left, WORD_SIZE);
    memcpy(left, right, WORD_SIZE);
    memcpy(right, temp, WORD_SIZE);
}

void stdin_to_buf();
void stdin_to_buf() {
    int word_size = 0;
    for (char* i = buf_stdin;; i++) {
        if (*i == '\0') break;
        if (*i == '\n') break;
        if (*i == ' ') {
            if (word_size == 0) continue;
            buf_words[word_count * WORD_SIZE + word_size] = '\0';
            word_count++;
            word_size = 0;
        } else {
            buf_words[(word_count * WORD_SIZE + word_size)] = *i;
            word_size++;
        }
    }
}

int partition(int low, int high);
int partition(int low, int high) {
    char* pivot = (char*)(buf_words + high * WORD_SIZE);
    int i = low - 1;
    for (int j = low; j < high; j++) {
        char* j_buf = (char*)(buf_words + j * WORD_SIZE);
        if (strncmp(j_buf, pivot, WORD_SIZE) < 0) {
            i++;
            char* i_buf = (char*)(buf_words + i * WORD_SIZE);
            swap(j_buf, i_buf);
        }
    }
    i++;
    char* i_buf = (char*)(buf_words + i * WORD_SIZE);
    char* high_buf = (char*)(buf_words + high * WORD_SIZE);
    swap(i_buf, high_buf);
    return i;
}

void sort_recursive(int low, int high);
void sort_recursive(int low, int high) {
    if (low < high) {
        int part = partition(low, high);

        sort_recursive(low, part - 1);
        sort_recursive(part + 1, high);
    }
}

void print_buf();
void print_buf() {
    for (int i = 0; i <= word_count; ++i) {
        char* s = (char*)(buf_words + i * WORD_SIZE);
        printf("%s ", s);
    }
}

int main() {
    word_count = 0;
    fgets(buf_stdin, sizeof(buf_stdin)-1, stdin);
    stdin_to_buf();
    sort_recursive(0, word_count);
    print_buf();
    return 0;
}