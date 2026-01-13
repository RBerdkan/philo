/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: rberdkan <rberdkan@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/01/09 00:12:33 by rberdkan          #+#    #+#             */
/*   Updated: 2026/01/12 18:13:37 by rberdkan         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "philo.h"

void	init_simulation(t_data *simulation, char **argv)
{
	simulation->philo_count = ft_atoi(argv[1]);
	simulation->time_to_die = ft_atoi(argv[2]);
	simulation->time_to_eat = ft_atoi(argv[3]);
	simulation->time_to_sleep = ft_atoi(argv[4]);
	if (argv[5])
		simulation->must_eat_count = ft_atoi(argv[5]);
	else
		simulation->must_eat_count = -1;
}

static int	allocate_all(t_data *simulation)
{
	if (allocate_forks(simulation))
	{
		write(2, "Error: failed to allocate forks\n", 33);
		return (1);
	}
	if (allocate_philos(simulation))
	{
		write(2, "Error: failed to allocate philos\n", 34);
		free(simulation->forks);
		return (1);
	}
	return (0);
}

static int	init_all(t_data *simulation)
{
	if (init_forks(simulation) || init_mutexes(simulation))
	{
		write(2, "Error: initialization failed\n", 30);
		cleanup(simulation);
		return (1);
	}
	simulation->start_time = get_time();
	simulation->dead_flag = 0;
	if (init_philos(simulation))
	{
		write(2, "Error: failed to init philos\n", 30);
		cleanup(simulation);
		return (1);
	}
	return (0);
}

static int	start_simulation(t_data *simulation)
{
	if (create_threads(simulation))
	{
		write(2, "Error: failed to create threads\n", 33);
		cleanup(simulation);
		return (1);
	}
	if (pthread_create(&simulation->monitor_thread, NULL,
			monitor_routine, simulation))
	{
		write(2, "Error: monitor thread failed\n", 30);
		cleanup(simulation);
		return (1);
	}
	join_threads(simulation);
	pthread_join(simulation->monitor_thread, NULL);
	return (0);
}

int	main(int argc, char **argv)
{
	t_data	simulation;

	if (argc != 5 && argc != 6)
	{
		write(2, "Error: wrong number of arguments\n", 34);
		return (1);
	}
	if (check_parameter(argc, argv))
		return (1);
	init_simulation(&simulation, argv);
	if (allocate_all(&simulation))
		return (1);
	if (init_all(&simulation))
		return (1);
	if (start_simulation(&simulation))
		return (1);
	cleanup(&simulation);
	return (0);
}
