typedef struct {
	unsigned long start;
	unsigned long end;
	unsigned long size;
	char * data;
} q_data;

int q_init (q_data * q, unsigned long size);
int q_term (q_data * q);
unsigned long q_write (char * data, unsigned long len, q_data * q);
unsigned long q_read (char * data, unsigned long len, q_data * q);
