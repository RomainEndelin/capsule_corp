activities = []


def naive_guess(event):
    if event['signal'] == 'ON':
        if event['attachement'] == 'Living Room':
            activity = 'Watch TV'
        elif event['attachement'] == 'Bedroom':
            activity = 'Sleep'
        elif event['attachement'] == 'Toilet':
            activity = 'Go Toilet'
        elif event['attachement'] == 'Kitchen':
            activity = 'Take Meal'
        activities.append(activity)
    else:
        activity = activities[-1] if activities else None
    return activity
