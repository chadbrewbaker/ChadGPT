#include <stdio.h>
#include <ctype.h>
#include <stdbool.h>

int main() {
    int c;
    long lines = 0, words = 0, chars = 0;
    bool in_word = false;

    while ((c = getchar()) != EOF) {
        chars++;

        if (c == '\n') {
            lines++;
        }

        if (isspace(c)) {
            in_word = false;
        } else if (!in_word) {
            in_word = true;
            words++;
        }
    }

    printf("%ld %ld %ld\n", lines, words, chars);

    return 0;
}
