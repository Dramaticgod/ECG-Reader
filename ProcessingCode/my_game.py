import pygame, sys, random

# Difficulty settings
difficulty = 25

# Window size
frame_size_x = 720
frame_size_y = 480

# Food size (increase this for larger food)
food_size = 30  # You can change this value to increase or decrease food size

def show_score(choice, color, font, size):
    score_font = pygame.font.SysFont(font, size)
    score_surface = score_font.render('Score : ' + str(score), True, color)
    score_rect = score_surface.get_rect()
    if choice == 1:
        score_rect.midtop = (frame_size_x/10, 15)
    else:
        score_rect.midtop = (frame_size_x/2, frame_size_y/1.25)
    game_window.blit(score_surface, score_rect)

# Function to read the file and check for non-zero values
def read_file_and_check(path_to_file):
    try:
        with open(path_to_file, "r") as file:
            lines = file.readlines()
            for line in lines:
                value = int(line.strip())
                if value != 0:
                    return True
        return False
    except FileNotFoundError:
        print(f"Error: File '{path_to_file}' not found.")
        return False
    except ValueError:
        print("Error: Could not convert file data to an integer.")
        return False

# Main function to run the Snake game
def main():
    path_to_file = r"C:\Users\jashs\OneDrive\Desktop\UIC FA24\Cs 479\Lab2\Lab-2-Jash\Lab-2-Jash\ProcessingCode\Test_FSR.txt"

    # Check if the file has any non-zero values
    if read_file_and_check(path_to_file):
        print("Non-zero value found! Starting the game.")

        # Initialise game window
        pygame.init()
        pygame.display.set_caption('Snake Eater')
        global game_window, snake_pos, snake_body, food_pos, food_spawn, direction, change_to, score, fps_controller
        game_window = pygame.display.set_mode((frame_size_x, frame_size_y))

        # Colors (R, G, B)
        black = pygame.Color(0, 0, 0)
        white = pygame.Color(255, 255, 255)
        green = pygame.Color(0, 255, 0)

        # FPS controller
        fps_controller = pygame.time.Clock()

        # Initialize game variables
        snake_pos = [100, 50]
        snake_body = [[100, 50], [100-10, 50], [100-(2*10), 50]]
        food_pos = [random.randrange(1, (frame_size_x//10)) * 10, random.randrange(1, (frame_size_y//10)) * 10]
        food_spawn = True
        direction = 'RIGHT'
        change_to = direction
        score = 0

        # Main game loop
        while True:
            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    pygame.quit()
                    sys.exit()
                elif event.type == pygame.KEYDOWN:
                    if event.key == pygame.K_UP or event.key == ord('w'):
                        change_to = 'UP'
                    if event.key == pygame.K_DOWN or event.key == ord('s'):
                        change_to = 'DOWN'
                    if event.key == pygame.K_LEFT or event.key == ord('a'):
                        change_to = 'LEFT'
                    if event.key == pygame.K_RIGHT or event.key == ord('d'):
                        change_to = 'RIGHT'
                    if event.key == pygame.K_ESCAPE:
                        pygame.event.post(pygame.event.Event(pygame.QUIT))

            if change_to == 'UP' and direction != 'DOWN':
                direction = 'UP'
            if change_to == 'DOWN' and direction != 'UP':
                direction = 'DOWN'
            if change_to == 'LEFT' and direction != 'RIGHT':
                direction = 'LEFT'
            if change_to == 'RIGHT' and direction != 'LEFT':
                direction = 'RIGHT'

            # Moving the snake
            if direction == 'UP':
                snake_pos[1] -= 10
            if direction == 'DOWN':
                snake_pos[1] += 10
            if direction == 'LEFT':
                snake_pos[0] -= 10
            if direction == 'RIGHT':
                snake_pos[0] += 10

            # Wrap around the screen (snake appears from the opposite side when hitting a border)
            if snake_pos[0] < 0:
                snake_pos[0] = frame_size_x - 10
            if snake_pos[0] > frame_size_x - 10:
                snake_pos[0] = 0
            if snake_pos[1] < 0:
                snake_pos[1] = frame_size_y - 10
            if snake_pos[1] > frame_size_y - 10:
                snake_pos[1] = 0

            # Snake growing mechanism
            snake_body.insert(0, list(snake_pos))
            # Adjust the food collision check to account for the new, larger food size
            if (food_pos[0] <= snake_pos[0] < food_pos[0] + food_size) and (food_pos[1] <= snake_pos[1] < food_pos[1] + food_size):
                score += 1
                food_spawn = False
            else:
                snake_body.pop()

            if not food_spawn:
                food_pos = [random.randrange(1, (frame_size_x//10)) * 10, random.randrange(1, (frame_size_y//10)) * 10]
            food_spawn = True

            # GFX
            game_window.fill(black)
            for pos in snake_body:
                pygame.draw.rect(game_window, green, pygame.Rect(pos[0], pos[1], 10, 10))

            # Draw larger food
            pygame.draw.rect(game_window, white, pygame.Rect(food_pos[0], food_pos[1], food_size, food_size))

            show_score(1, white, 'consolas', 20)
            pygame.display.update()
            fps_controller.tick(difficulty)
    else:
        print("No non-zero values found. Exiting.")

if __name__ == "__main__":
    main()
