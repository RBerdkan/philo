NAME = philo

CC = cc
CFLAGS = -Wall -Wextra -Werror -pthread

SRCS = main.c ft_atoi.c init.c routine.c utils.c monitor.c thread.c
OBJS = $(SRCS:.c=.o)

all: $(NAME)

$(NAME): $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o $(NAME)

clean:
	rm -f $(OBJS)

fclean: clean
	rm -f $(NAME)

re: fclean all

.PHONY: all clean fclean re
