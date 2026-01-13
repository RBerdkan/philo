/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   init.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: rberdkan <rberdkan@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/01/09 20:29:17 by rberdkan          #+#    #+#             */
/*   Updated: 2026/01/12 18:56:23 by rberdkan         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "philo.h"

int	init_forks(t_data *sim)
{
	int	i;

	i = 0;
	while (i < sim->philo_count)
	{
		if (pthread_mutex_init(&sim->forks[i], NULL))
			return (1);
		i++;
	}
	return (0);
}

int	init_mutexes(t_data *sim)
{
	if (pthread_mutex_init(&sim->print_mutex, NULL) != 0)
		return (1);
	if (pthread_mutex_init(&sim->death_mutex, NULL) != 0)
		return (1);
	return (0);
}

static void	assign_forks(t_data *sim, int i)
{
	if (i % 2 == 0)
	{
		sim->philos[i].left_fork = &sim->forks[i];
		sim->philos[i].right_fork = &sim->forks[(i + 1) % sim->philo_count];
	}
	else
	{
		sim->philos[i].left_fork = &sim->forks[(i + 1) % sim->philo_count];
		sim->philos[i].right_fork = &sim->forks[i];
	}
}

int	init_philos(t_data *sim)
{
	int		i;
	long	start;

	start = get_time();
	i = 0;
	while (i < sim->philo_count)
	{
		sim->philos[i].id = i + 1;
		sim->philos[i].meals_eaten = 0;
		sim->philos[i].last_meal_time = start;
		assign_forks(sim, i);
		sim->philos[i].data = sim;
		i++;
	}
	return (0);
}
