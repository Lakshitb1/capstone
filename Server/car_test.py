import numpy as np
import pandas as pd
import random


def simulate_pothole_data(duration=1, freq=50):  # y: [lower limit -5]
    time = np.linspace(0, duration, int(duration * freq))
    
    # Generate acc_x with values either in [-4, -1.5] or [1.5, 4]
    range1 = np.random.uniform(-2, -0.5, size=time.shape[0] // 2)
    range2 = np.random.uniform(0.5, 2, size=time.shape[0] - time.shape[0] // 2)
    acc_x = np.concatenate([range1, range2])
    np.random.shuffle(acc_x)  # Shuffle to mix values from both ranges
    
    # Generate acc_y and acc_z
    acc_y = np.random.uniform(-2, -0.25, size=time.shape)
    acc_z = np.random.uniform(-0.05, 0.05, size=time.shape)
    
    # Round values to 6 decimal places
    acc_x = np.round(acc_x, 6)
    acc_y = np.round(acc_y, 6)
    acc_z = np.round(acc_z, 6)
    
    return time, acc_x, acc_y, acc_z


def simulate_bump_data(duration=1, freq=50):  # y: [upper limit 5]
    time = np.linspace(0, duration, int(duration * freq))
    
    # Generate acc_x with values either in [-4, -1.5] or [1.5, 4]
    range1 = np.random.uniform(-2, -0.25, size=time.shape[0] // 2)
    range2 = np.random.uniform(0.5, 2, size=time.shape[0] - time.shape[0] // 2)
    acc_x = np.concatenate([range1, range2])
    np.random.shuffle(acc_x)  # Shuffle to mix values from both ranges
    
    # Generate acc_y and acc_z
    acc_y = np.random.uniform(0.5, 2, size=time.shape)
    acc_z = np.random.uniform(-0.05, 0.05, size=time.shape)
    
    # Round values to 6 decimal places
    acc_x = np.round(acc_x, 6)
    acc_y = np.round(acc_y, 6)
    acc_z = np.round(acc_z, 6)
    
    return time, acc_x, acc_y, acc_z


def simulate_normal_data(duration=1, freq=100):
    time = np.linspace(0, duration, int(duration * freq))
    
    # Generate acc_x, acc_y, acc_z
    acc_x = np.random.uniform(-0.05, 0.05, size=time.shape)
    acc_y = np.random.uniform(-0.05, 0.05, size=time.shape)
    acc_z = np.random.uniform(-0.05, 0.05, size=time.shape)
    
    # Round values to 6 decimal places
    acc_x = np.round(acc_x, 6)
    acc_y = np.round(acc_y, 6)
    acc_z = np.round(acc_z, 6)
    
    return time, acc_x, acc_y, acc_z

def generate_dataset(num_events=10):
    event_types = ['pothole', 'bump', 'normal']
    data = []
    
    for event in event_types:
        for _ in range(num_events):
            if event == 'pothole':
                time, acc_x, acc_y, acc_z = simulate_pothole_data()
            elif event == 'bump':
                time, acc_x, acc_y, acc_z = simulate_bump_data()
            else:
                time, acc_x, acc_y, acc_z = simulate_normal_data()
            
            for i in range(len(time)):
                data.append([acc_x[i], acc_y[i], acc_z[i], event])
    
    df = pd.DataFrame(data, columns=['x', 'y', 'z', 'label'])
    df = df.sample(frac=1).reset_index(drop=True)
    return df



#-----------------------------------------------

df = generate_dataset()

# Save the dataset to a CSV file
df.to_csv('car_test.csv', index=False)
print("Dataset saved as 'simulated_pothole_bump_dataset.csv'")





# def interpret_label(fuzzy_label_output):
#     if fuzzy_label_output <= 3.3:
#         return 'normal'
#     elif 3.4 <= fuzzy_label_output <= 6.6:
#         return 'bump'
#     else:
#         return 'pothole'