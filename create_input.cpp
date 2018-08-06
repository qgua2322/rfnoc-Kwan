#include <stdio.h>
#include <stdlib.h>

int main(void){
    int i, retval;
     FILE * fp_out = fopen("test_in.bin","wb");

    if (fp_out == NULL){
        printf("Could not open the test_in.bin!\n");
        exit(1);
    }

    int NumPacket = 10000;
    int * outs = (int*) malloc ((NumPacket+1)*2*sizeof(int));
    
    outs[0] = 0xabcdbeef;
    outs[1] = 0xdeadbeef;
    for(i=1;i<(NumPacket+1);i++){
        outs[2*i] = 0xabcdbeef;
        outs[2*i+1] = i;
    }

    fwrite(outs,(NumPacket+1)*2*sizeof(int),1,fp_out);

    return 0;
}
