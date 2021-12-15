#include <stdio.h>
#include <stdlib.h>

int main(int argc, char** argv) {
	char c = 0;
	while((c = fgetc(stdin)) != EOF) {
		fputc(c, stdout);
		if(c == '\n') {
			fflush(stdout);
		}
}	
	return EXIT_SUCCESS;
}
