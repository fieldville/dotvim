TARGET=$(shell basename $(CURDIR))
CC=gcc
CFLAGS= -O2 -Wall -std=gnu99
SRCS=$(wildcard *.c)
OBJS=$(SRCS:%.c=%.o)
HEADERS=$(wildcard *.h)
LDFLAGS= -lm
.PHONY: all clean

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

%o: %c $(HEADERS)
	$(CC) $(CFLAGS) -c $<

clean:
	$(RM) $(OBJS) $(TARGET)
