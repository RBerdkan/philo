/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   routine.c                                          :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: rberdkan <rberdkan@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/01/11 16:17:00 by rberdkan          #+#    #+#             */
/*   Updated: 2026/01/13 20:05:32 by rberdkan         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "philo.h"

static int	should_stop(t_philo *philo)
{
	int	stop;

	pthread_mutex_lock(&philo->data->death_mutex);
	stop = philo->data->dead_flag;
	pthread_mutex_unlock(&philo->data->death_mutex);
	return (stop);
}

static int	reached_meal_limit(t_philo *philo)
{
	int	meals;

	if (philo->data->must_eat_count == -1)
		return (0);
	pthread_mutex_lock(&philo->data->death_mutex);
	meals = philo->meals_eaten;
	pthread_mutex_unlock(&philo->data->death_mutex);
	return (meals >= philo->data->must_eat_count);
}

static void	philo_eat(t_philo *philo)
{
	pthread_mutex_lock(philo->left_fork);
	print_status(philo, "has taken a fork");
	pthread_mutex_lock(philo->right_fork);
	print_status(philo, "has taken a fork");
	print_status(philo, "is eating");
	pthread_mutex_lock(&philo->data->death_mutex);
	philo->last_meal_time = get_time();
	pthread_mutex_unlock(&philo->data->death_mutex);
	ft_usleep(philo->data->time_to_eat);
	pthread_mutex_lock(&philo->data->death_mutex);
	philo->meals_eaten++;
	pthread_mutex_unlock(&philo->data->death_mutex);
	pthread_mutex_unlock(philo->right_fork);
	pthread_mutex_unlock(philo->left_fork);
}

static void	philo_sleep_think(t_philo *philo)
{
	print_status(philo, "is sleeping");
	ft_usleep(philo->data->time_to_sleep);
	print_status(philo, "is thinking");
}

void	*philosopher_routine(void *arg)
{
	t_philo	*philo;

	philo = (t_philo *)arg;
	if (philo->data->philo_count == 1)
	{
		pthread_mutex_lock(philo->left_fork);
		print_status(philo, "has taken a fork");
		ft_usleep(philo->data->time_to_die);
		pthread_mutex_unlock(philo->left_fork);
		return (NULL);
	}
	if (philo->id % 2 == 0)
		usleep(100);
	while (1)
	{
		if (should_stop(philo) || reached_meal_limit(philo))
			break ;
		philo_eat(philo);
		philo_sleep_think(philo);
	}
	return (NULL);
}
