/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   utils.c                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: rberdkan <rberdkan@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/01/11 16:22:17 by rberdkan          #+#    #+#             */
/*   Updated: 2026/01/12 21:15:27 by rberdkan         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "philo.h"

long	get_time(void)
{
	struct timeval	tv;

	gettimeofday(&tv, NULL);
	return (tv.tv_sec * 1000 + tv.tv_usec / 1000);
}

void	ft_usleep(long milliseconds)
{
	long	start;

	start = get_time();
	while (get_time() - start < milliseconds)
		usleep(500);
}

void	print_status(t_philo *philo, char *status)
{
	long	timestamp;
	int		dead;

	pthread_mutex_lock(&philo->data->print_mutex);
	pthread_mutex_lock(&philo->data->death_mutex);
	dead = philo->data->dead_flag;
	pthread_mutex_unlock(&philo->data->death_mutex);
	if (dead == 1)
	{
		pthread_mutex_unlock(&philo->data->print_mutex);
		return ;
	}
	timestamp = get_time() - philo->data->start_time;
	printf("%ld %d %s\n", timestamp, philo->id, status);
	pthread_mutex_unlock(&philo->data->print_mutex);
}

void	cleanup(t_data *sim)
{
	int	i;

	i = 0;
	while (i < sim->philo_count)
	{
		pthread_mutex_destroy(&sim->forks[i]);
		i++;
	}
	pthread_mutex_destroy(&sim->print_mutex);
	pthread_mutex_destroy(&sim->death_mutex);
	free(sim->forks);
	free(sim->philos);
}

int	check_parameter(int argc, char **argv)
{
	int	i;
	int	value;

	i = 1;
	while (i < argc)
	{
		if (!is_number(argv[i]))
		{
			write(2, "argument error\n", 15);
			return (1);
		}
		value = ft_atoi(argv[i]);
		if (value <= 0)
		{
			write(2, "argument error\n", 15);
			return (1);
		}
		i++;
	}
	return (0);
}
