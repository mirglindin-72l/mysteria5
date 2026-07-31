int q_init (q_data * q,unsigned long size) {
	puts("q_init");
	q->start = 0;
	q->end = 1;
	q->size = size;
	q->data = malloc(size);	
	for (unsigned long i = 0 ; i < size ; i++) {
		q->data[i] = 0;
	}
	printf("ret ptr %td\n",q);
	puts("q_init end");
	return 0;
}

int q_term (q_data * q) {
	puts("q_term");
	printf("ptr %td\n",q);
	if (q->data != NULL) {
		free(q->data);
		q->data = NULL;
	}
	q->start = 0;
	q->end = 0;
	q->size = 0;
	puts("q_term end");
	return 0;
}

/*
 write to queue from buffer indicated by pointer,
 advance end (regardless, but then also move start before it)
*/

unsigned long q_write (char * data, unsigned long len, q_data * q) {
	puts("q_write");
	//printf("ptr %td\n",q);
	//printf("q->size %td\n",q->size);
	for (unsigned long i = 0 ; i < len ; i++) {
		//printf("i %td\n",i);
		q->data[((q->end + i) % q->size)] = data[i];
		//printf("data[.]= %c\n",data[i]);
	}
	q->end = ( q->end + len ) % q->size;
	printf("q_write ret %td\n",len);
	//puts("q_write end");
	return len;
}

/*
 read from queue to buffer indicated by pointer,
 advance start (not further than end)
*/

unsigned long q_read (char * data, unsigned long len, q_data * q) {
	puts("q_read");
	//printf("ptr %td\n",q);
	//printf("q->size %td\n",q->size);
	unsigned long c = 0;
	for (c = 0 ; c < len && (q->start + c) != q->end ; c++) {
		//printf("c %td\n",c);
		data[c] = q->data[((q->start + c) % q->size)];
		//printf("data[.]= %c\n",data[c]);
	}
	q->start = (q->start + c) % q->size;
	printf("q_read ret %td\n",c);
	//puts("q_read end");
	return c;
}
