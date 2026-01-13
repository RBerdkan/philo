/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   monitor.c                                          :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: rberdkan <rberdkan@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/01/11 17:19:29 by rberdkan          #+#    #+#             */
/*   Updated: 2026/01/13 19:10:37 by rberdkan         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "philo.h"

static int	check_death(t_philo *philo)
{
    long	current_time;
    long	time_since_meal;
    long	last_meal;

    pthread_mutex_lock(&philo->data->death_mutex);
    last_meal = philo->last_meal_time;
    pthread_mutex_unlock(&philo->data->death_mutex);
    current_time = get_time();
    time_since_meal = current_time - last_meal;
    if (time_since_meal > philo->data->time_to_die)
    {
        print_status(philo, "died");
        pthread_mutex_lock(&philo->data->death_mutex);
        philo->data->dead_flag = 1;
        pthread_mutex_unlock(&philo->data->death_mutex);
        return (1);
    }
    return (0);
}

static int	philo_finished_eating(t_data *data, int i)
{
    int	meals;

    pthread_mutex_lock(&data->death_mutex);
    meals = data->philos[i].meals_eaten;
    pthread_mutex_unlock(&data->death_mutex);
    return (meals >= data->must_eat_count);
}

static int	check_meals_complete(t_data *data)
{
    int	i;

    if (data->must_eat_count == -1)
        return (0);
    i = 0;
    while (i < data->philo_count)
    {
        if (!philo_finished_eating(data, i))
            return (0);
        i++;
    }
    pthread_mutex_lock(&data->death_mutex);
    data->dead_flag = 1;
    pthread_mutex_unlock(&data->death_mutex);
    return (1);
}

void	*monitor_routine(void *arg)
{
    t_data	*data;
    int		i;

    data = (t_data *)arg;
    usleep(1000);
    while (1)
    {
        if (check_meals_complete(data))
            return (NULL);
        i = 0;
        while (i < data->philo_count)
        {
            if (check_death(&data->philos[i]))
                return (NULL);
            i++;
        }
        usleep(1000);
    }
    return (NULL);
}