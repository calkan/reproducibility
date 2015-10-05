#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <zlib.h>

#define MAX_SEQUENCE_LENGTH 200
char **sequences;
char **sequence_names;
char **qualities;
char **sequences2;
char **sequence_names2;
char **qualities2;

main(int argc, char **argv){
  char tmp[500];
  unsigned int i, j, s;
  FILE *in;
  FILE *in2;
  FILE *out;
  FILE *out2;
  gzFile gzipped_in;
  gzFile gzipped_in2;
  gzFile gzipped_out;
  gzFile gzipped_out2;
  int copies;
  char outfname[MAX_SEQUENCE_LENGTH];
  char outprefix[MAX_SEQUENCE_LENGTH];
  char ch;
  int seqcnt=0;
  int gzmode=0;

  char name[MAX_SEQUENCE_LENGTH]; char qual[MAX_SEQUENCE_LENGTH]; char seq[MAX_SEQUENCE_LENGTH];
  
  if (argc != 4){
    printf("Shuffles a given pair of FASTQ sequence files.\n");
    printf("%s [infile_1.fq] [infile_2.fq] [outprefix]\n", argv[0]);
    exit(0);
  }

  if (argv[1][strlen(argv[1])-1] == 'z' && argv[1][strlen(argv[1])-2] == 'g') // cheap trick
    gzmode = 1;

  if (!gzmode){

    if ((in = fopen(argv[1], "r")) == NULL){
      printf("Unable  to open file %s\n", argv[1]);
      exit (0);
    }
    
    if ((in2 = fopen(argv[2], "r")) == NULL){
      printf("Unable  to open file %s\n", argv[2]);
      exit (0);
    }
  }
  else{
    if ((gzipped_in = gzopen(argv[1], "r")) == NULL){
      printf("Unable  to open file %s\n", argv[1]);
      exit (0);
    }
    
    if ((gzipped_in2 = gzopen(argv[2], "r")) == NULL){
      printf("Unable  to open file %s\n", argv[2]);
      exit (0);
    }
  }

  strcpy(outprefix, argv[3]);
  
  fprintf(stderr, "Scanning.\n");

  if (!gzmode){
    while (!feof(in)){
      fgets(tmp, MAX_SEQUENCE_LENGTH, in); 
      if (feof(in)) break;
      fgets(tmp, MAX_SEQUENCE_LENGTH, in);
      fgets(tmp, MAX_SEQUENCE_LENGTH, in); // + line
      fgets(tmp, MAX_SEQUENCE_LENGTH, in);    
      
      seqcnt++;
    }
    rewind(in);
  }
  else{
    while (!gzeof(gzipped_in)){
      gzgets(gzipped_in, tmp, MAX_SEQUENCE_LENGTH); 
      if (gzeof(gzipped_in)) break;
      gzgets(gzipped_in, tmp, MAX_SEQUENCE_LENGTH);
      gzgets(gzipped_in, tmp, MAX_SEQUENCE_LENGTH); // + line
      gzgets(gzipped_in, tmp, MAX_SEQUENCE_LENGTH);    
      
      seqcnt++;
    }
    gzrewind(gzipped_in);
  }

  sequences = (char **) malloc(sizeof(char *) * seqcnt);
  sequence_names = (char **) malloc(sizeof(char *) * seqcnt);
  qualities = (char **) malloc(sizeof(char *) * seqcnt);

  sequences2 = (char **) malloc(sizeof(char *) * seqcnt);
  sequence_names2 = (char **) malloc(sizeof(char *) * seqcnt);
  qualities2 = (char **) malloc(sizeof(char *) * seqcnt);


  for (i=0;i<seqcnt;i++){
    sequences[i] = (char *) malloc(sizeof(char) * MAX_SEQUENCE_LENGTH);
    sequence_names[i] = (char *) malloc(sizeof(char) * MAX_SEQUENCE_LENGTH);
    qualities[i] = (char *) malloc(sizeof(char) * MAX_SEQUENCE_LENGTH);
    sequences2[i] = (char *) malloc(sizeof(char) * MAX_SEQUENCE_LENGTH);
    sequence_names2[i] = (char *) malloc(sizeof(char) * MAX_SEQUENCE_LENGTH);
    qualities2[i] = (char *) malloc(sizeof(char) * MAX_SEQUENCE_LENGTH);
  }

  i = 0; j =0;

  fprintf(stderr, "Loading %d sequences.\n", seqcnt);

  if (!gzmode){
    while (!feof(in)){
      fgets(sequence_names[i], MAX_SEQUENCE_LENGTH, in); 
      if (feof(in)) break;
      fgets(sequences[i], MAX_SEQUENCE_LENGTH, in);
      fgets(tmp, MAX_SEQUENCE_LENGTH, in); // + line
      fgets(qualities[i], MAX_SEQUENCE_LENGTH, in);
      
      fgets(sequence_names2[i], MAX_SEQUENCE_LENGTH, in2); 
      fgets(sequences2[i], MAX_SEQUENCE_LENGTH, in2);
      fgets(tmp, MAX_SEQUENCE_LENGTH, in2); // + line
      fgets(qualities2[i], MAX_SEQUENCE_LENGTH, in2);
      
      i++;
    }
  }
  else{
    while (!gzeof(gzipped_in)){
      gzgets(gzipped_in, sequence_names[i], MAX_SEQUENCE_LENGTH); 
      if (gzeof(gzipped_in)) break;
      gzgets(gzipped_in, sequences[i], MAX_SEQUENCE_LENGTH);
      gzgets(gzipped_in, tmp, MAX_SEQUENCE_LENGTH); // + line
      gzgets(gzipped_in, qualities[i], MAX_SEQUENCE_LENGTH);
      
      gzgets(gzipped_in2, sequence_names2[i], MAX_SEQUENCE_LENGTH); 
      gzgets(gzipped_in2, sequences2[i], MAX_SEQUENCE_LENGTH);
      gzgets(gzipped_in2, tmp, MAX_SEQUENCE_LENGTH); // + line
      gzgets(gzipped_in2, qualities2[i], MAX_SEQUENCE_LENGTH);
      
      i++;
    }
  }

  fprintf(stderr, "Loaded %d/%d sequences.\n", i, seqcnt);


  srand(time(NULL));

  fprintf(stderr, "Shuffling.\n");
  for (i=0; i<seqcnt; i++){
    j = rand() % seqcnt;
    strcpy(seq, sequences[i]);
    strcpy(sequences[i], sequences[j]);
    strcpy(sequences[j], seq);
    
    strcpy(qual, qualities[i]);
    strcpy(qualities[i], qualities[j]);
    strcpy(qualities[j], qual);
    
    strcpy(name, sequence_names[i]);
    strcpy(sequence_names[i], sequence_names[j]);
    strcpy(sequence_names[j], name);
    
    strcpy(seq, sequences2[i]);
    strcpy(sequences2[i], sequences2[j]);
    strcpy(sequences2[j], seq);

    strcpy(qual, qualities2[i]);
    strcpy(qualities2[i], qualities2[j]);
    strcpy(qualities2[j], qual);
    
    strcpy(name, sequence_names2[i]);
    strcpy(sequence_names2[i], sequence_names2[j]);
    strcpy(sequence_names2[j], name);
  }
  

  if (!gzmode){
    sprintf(outfname, "%sshuf_1.fq", outprefix);
    out = fopen(outfname, "w");
    sprintf(outfname, "%sshuf_2.fq", outprefix);
    out2 = fopen(outfname, "w");
    
    for (i=0; i<seqcnt; i++){
      fprintf(out, "%s%s+\n%s", sequence_names[i], sequences[i], qualities[i]);
      fprintf(out2, "%s%s+\n%s", sequence_names2[i], sequences2[i], qualities2[i]);
    }
    
    fclose(out); fclose(out2);
  }
  else{
    sprintf(outfname, "%sshuf_1.fq.gz", outprefix);
    gzipped_out = gzopen(outfname, "w");
    sprintf(outfname, "%sshuf_2.fq.gz", outprefix);
    gzipped_out2 = gzopen(outfname, "w");
  
    for (i=0; i<seqcnt; i++){
      gzprintf(gzipped_out, "%s%s+\n%s", sequence_names[i], sequences[i], qualities[i]);
      gzprintf(gzipped_out2, "%s%s+\n%s", sequence_names2[i], sequences2[i], qualities2[i]);
    }
  
    gzclose(gzipped_out); gzclose(gzipped_out2);
  }
}
