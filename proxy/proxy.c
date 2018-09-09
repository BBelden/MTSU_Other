// Name:        Ben Belden
// Class ID#:   bpb2v
// Section:     CSCI 5300-001
// Assignment:  Project Part 2
// Due:         23:30:00, December 12, 2017
// Purpose:  	Implement a daemon process that acts as a general TCP proxy server.
// Input:       From web-socket.  
// Outut:       To terminal.
// 
// File:        proxy.c

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <netdb.h>
#include <netinet/in.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <unistd.h>

void HandleClientConnection(int newsocket)
{
	char ppbuf[2048];
	char cookie[sizeof(ppbuf)];
	char method[sizeof(ppbuf)];
	char phost[sizeof(ppbuf)];
	char protocol[sizeof(ppbuf)];
	char url[sizeof(ppbuf)];
	int index=0;
	int iolen;
	int newsocket2;
	ssize_t bytes_read;
	struct hostent *newserver;
	struct protoent *ptrp;
	struct sockaddr_in sad;
	fd_set rdfdset;

	bytes_read = read(newsocket,ppbuf,2047);
	if(bytes_read>0)  ppbuf[bytes_read]='\0';
	fprintf(stderr,"REQUEST OF CLIENT:\n%s\nEND OF REQUEST\n",ppbuf);

	for(;index<bytes_read;index++){
		if(strncmp("GET",ppbuf+index,3)==0){
			strncpy(method,"GET",3);	
			sscanf(ppbuf+index+3,"%s %s",url,protocol);
		}
		else if(strncmp("POST",ppbuf+index,4)==0)  strncpy(method,"POST",4);
		else if(strncmp("CONNECT",ppbuf+index,7)==0)  strncpy(method,"CONNECT",7);	
		else if(strncmp("Host:",ppbuf+index,5)==0)  sscanf(ppbuf+index+5,"%s",phost);
		else if(strncmp("Cookie:",ppbuf+index,7)==0)  sscanf(ppbuf+index+7,"%s",cookie);
	}
	
	newserver = gethostbyname(phost);
	if(newserver==NULL)  fprintf(stderr,"No such host!\n");
	bzero((char *)&sad,sizeof(sad));
	sad.sin_family = AF_INET;
	bcopy((char *)newserver->h_addr,(char *)&sad.sin_addr.s_addr,newserver->h_length);

	if(strncmp("GET",method,3)==0)  sad.sin_port = htons((u_short)80);
	else if(strncmp("CONNECT",method,7)==0)  sad.sin_port = htons((u_short)443);
	else  sad.sin_port = htons((u_short)80);

	ptrp = getprotobyname("tcp");
	if(ptrp==0)  fprintf(stderr,"Can't get tcp protocol entry");
	
	newsocket2 = socket(PF_INET,SOCK_STREAM,ptrp->p_proto);
	
	int connstat=connect(newsocket2,(struct sockaddr *)&sad,sizeof(sad));
	if(connstat<0)  fprintf(stderr,"Can't connect to the web server\n");
	
	write(newsocket2,ppbuf,sizeof(ppbuf));
	
	while(1){
		FD_ZERO(&rdfdset);
		FD_SET(newsocket,&rdfdset);
		FD_SET(newsocket2,&rdfdset);
		if(select(FD_SETSIZE,&rdfdset,NULL,NULL,NULL)<0)
			fprintf(stderr,"select failed\n");
		if(FD_ISSET(newsocket,&rdfdset)){
			if((iolen = read(newsocket,ppbuf,sizeof(ppbuf)))<=0)  break;
			write(newsocket2,ppbuf,iolen);
		}
		if(FD_ISSET(newsocket2,&rdfdset)){
			if((iolen = read(newsocket2,ppbuf,sizeof(ppbuf)))<=0)  break;
			write(newsocket,ppbuf,iolen);
		}
	}
	close(newsocket2);
}


int main(int argc, char *argv[])
{
	int port;				/* protocol port number */
	int sd0,sd1;			/* socket descriptors */
	struct hostent *ptrh;	/* pointer to a host table entry */
	struct protoent *ptrp;	/* pointer to a protocol table entry */
	struct sockaddr_in sad;	/* structure to hold server's address */
	struct sockaddr_in cad;	/* structure to hold client's address */
	socklen_t addrlen;		/* length of address */
	pid_t pid;
	
	memset((char *)&sad,0,sizeof(sad));	/* clear sockaddr structure */
	sad.sin_family = AF_INET;			/* set family to Internet */
	sad.sin_addr.s_addr = INADDR_ANY;	/* set the local IP address */
	port = atoi(argv[1]);				/* use the specified port number */
	
	if(port>0)  sad.sin_port = htons((u_short)port);
	else{	
		fprintf(stderr,"Bad port number %d!\n",port);
		exit(1);
	}
	ptrp = getprotobyname("tcp");
	if(ptrp==0){	
		fprintf(stderr,"Can't get tcp protocol entry!\n");
		exit(1);
	}
	sd0 = socket(PF_INET,SOCK_STREAM,ptrp->p_proto);
	if(sd0<0){
		fprintf(stderr,"Can't create socket!\n");
		exit(1);
	}
	if(bind(sd0,(struct sockaddr *)&sad,sizeof(sad))<0){
		fprintf(stderr,"Can't bind socket!\n");
		exit(1);
	}

	listen(sd0,5);

	while(1)
	{
		addrlen = sizeof(cad);
		sd1 = accept(sd0,(struct sockaddr *)&cad,&addrlen);
		if(sd1<0)  fprintf(stderr,"Can't accept socket\n");
		signal(SIGTTOU,SIG_IGN);
		signal(SIGTTIN,SIG_IGN);
		signal(SIGTSTP,SIG_IGN);
		pid = fork();
		if(pid ==0){
			close(sd0);
			HandleClientConnection(sd1);
			break;
		}else{
			close(sd1);
			continue;
		}
	}
	return 0;
}

