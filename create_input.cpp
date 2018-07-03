#include <stdio.h>
#include <stdlib.h>

int main(void){
    int i, retval;
     FILE * fp_out = fopen("test_in.bin","wb");

    if (fp_out == NULL){
        printf("Could not open the test_in.bin!\n");
        exit(1);
    }

    int * outs = (int*) malloc (22*sizeof(int));

    outs[0] = 0xabcd0000;
    outs[1] = 0xdeadbeef;
    for(i=1;i<11;i++){
        outs[2*i] = 0xabcd0000;
        outs[2*i+1] = i;
    }

    fwrite(outs,22*sizeof(int),1,fp_out);

    return 0;
}
