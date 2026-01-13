/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   thread.c                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: rberdkan <rberdkan@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/01/12 18:47:35 by rberdkan          #+#    #+#             */
/*   Updated: 2026/01/12 18:56:27 by rberdkan         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "philo.h"

int	allocate_forks(t_data *sim)
{
	sim->forks = malloc(sizeof(pthread_mutex_t) * sim->philo_count);
	if (!sim->forks)
		return (1);
	return (0);
}

int	allocate_philos(t_data *sim)
{
	sim->philos = malloc(sizeof(t_philo) * sim->philo_count);
	if (!sim->philos)
		return (1);
	return (0);
}

int	create_threads(t_data *sim)
{
	int	i;

	i = 0;
	while (i < sim->philo_count)
	{
		if (pthread_create(&sim->philos[i].thread, NULL,
				philosopher_routine, &sim->philos[i]))
		{
			write(2, "Error: thread creation failed\n", 31);
			return (1);
		}
		i++;
	}
	return (0);
}

int	join_threads(t_data *sim)
{
	int	i;

	i = 0;
	while (i < sim->philo_count)
	{
		if (pthread_join(sim->philos[i].thread, NULL))
		{
			write(2, "Error: thread join failed\n", 27);
			return (1);
		}
		i++;
	}
	return (0);
}
