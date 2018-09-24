# Core Motion and SpriteKit
### This is assignment is shorter than other assignments and worth fewer points.
#### Module A
Create an iOS application that:
- Displays the number of steps a user has walked today and display the number of steps a user walked yesterday
- Displays a realtime count of the number of steps a users has taken today (this could be the same label as "number of steps today")
- Displays the number of steps until the user reaches a (user settable) daily goal (the goal should be saved persistently so that it is remembered even when the app restarts) 
- Displays the current activity of the user: {unknown, still, walking, running, cycling, driving}

#### Module B
Create an additional part of the app that, whenever the user meets their step goal for the previous day, allows the playing of a simple game (it can be very simple). The game must: 
- Uses {acceleration, gyro, magnetometer, OR fused motion} to control some part of the physics of a SpriteKit (or SceneKit) game
- Uses two or more SpriteKit (or SceneKit) objects with dynamic physics
- An idea for exceptional work **(required for 7000 level students)**: use the steps of a user as some type of "currency" in the game to incentivize movement during the dayfrequency

The application should make use of the M- co-processor whenever possible. Verify the functionality of the application to the instructor during lab time or office hours (or scheduled via email). 

Turn in the source code for your app in zipped format or via GitHub (Upload as "teamNameAssignmentThree.zip"). Use proper coding techniques and naming conventions for objective C. Include your team member names and team name in the comments of the "main.m" file as well as in upload text.

#### Grading Rubric
- [10 points] Proper Interface Design 
- [10 points] Proper Coding Techniques for Swift/Objective C
- [40 points] Module A (acitivity accessed properly, steps counted correctly, goals setting)
- [30 points] Module B (SpriteKit/SceneKit used properly, physics, proper motion access, etc.)
- [10 points] Exceptional (free reign to make updates, perhaps on the interface side)
