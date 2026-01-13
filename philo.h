/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   philo.h                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: rberdkan <rberdkan@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/01/12 18:11:24 by rberdkan          #+#    #+#             */
/*   Updated: 2026/01/12 18:57:02 by rberdkan         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef PHILO_H
# define PHILO_H

# include <pthread.h>
# include <stdio.h>
# include <stdlib.h>
# include <sys/time.h>
# include <unistd.h>

typedef struct s_data	t_data;

typedef struct s_philo
{
	int				id;
	int				meals_eaten;
	long			last_meal_time;
	pthread_t		thread;
	pthread_mutex_t	*left_fork;
	pthread_mutex_t	*right_fork;
	t_data			*data;
}	t_philo;

typedef struct s_data
{
	int				philo_count;
	long			time_to_die;
	long			time_to_eat;
	long			time_to_sleep;
	int				must_eat_count;
	long			start_time;
	int				dead_flag;
	pthread_t		monitor_thread;
	pthread_mutex_t	*forks;
	pthread_mutex_t	print_mutex;
	pthread_mutex_t	death_mutex;
	t_philo			*philos;
}	t_data;

/* Initialization */
int		allocate_forks(t_data *simulation);
int		allocate_philos(t_data *simulation);
int		init_forks(t_data *simulation);
int		init_mutexes(t_data *simulation);
int		init_philos(t_data *simulation);
int		create_threads(t_data *simulation);
int		join_threads(t_data *simulation);
/* Routines */
void	*philosopher_routine(void *arg);
void	*monitor_routine(void *arg);

/* Utils */
long	get_time(void);
void	ft_usleep(long milliseconds);
void	print_status(t_philo *philo, char *status);
void	cleanup(t_data *simulation);
int		check_parameter(int argc, char **argv);
int		ft_atoi(const char *str);
int		is_number(char *str);

/* Main */
void	init_simulation(t_data *simulation, char **argv);

#endif