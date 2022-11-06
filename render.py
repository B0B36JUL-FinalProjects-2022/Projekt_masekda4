import argparse
import pygame
from pathlib import Path
from PIL import Image

parser = argparse.ArgumentParser()
parser.add_argument('--input', type=Path)
parser.add_argument('--speed', type=int, default=30, help="PyGame display delay")
parser.add_argument('--duration', type=int, default=10, help='GIF frame duration')

COLOR_BACKGROUND = (0, 0, 0)
COLOR_SNAKE = (28, 125, 22)
COLOR_HEAD = (58, 186, 51)
COLOR_FOOD = (158, 8, 8)
COLOR_SCORE = (255, 255, 255)
COLOR_BLOCK = (30, 30, 30)

FONT_SIZE = 20
BLOCK_SIZE = 40
BLOCK_SIZE_SNAKE = BLOCK_SIZE
BLOCK_SIZE_FOOD = BLOCK_SIZE * 0.8


def main(args):
    pygame.init()

    FONT = pygame.font.SysFont("arial", FONT_SIZE)

    with open(args.input) as fh:
        lines = fh.readlines()
    
    parts = lines[0].split('|')[:-1]
    H = len(parts)
    W = len(parts[0])

    SCREEN_W = W * BLOCK_SIZE
    SCREEN_H = H * BLOCK_SIZE

    dis = pygame.display.set_mode((SCREEN_W, SCREEN_H))
    pygame.display.set_caption('Snakey')
    clock = pygame.time.Clock()

    foodx = 3
    foody = 4
    score = 123.3
    headx = 1
    heady = 3
    imgs = []


    snake = [[1,1],[1,2],[1,3]]
    blocks = [[0,0], [0,1]]

    running = True
    for line in lines:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
            elif event.type == pygame.KEYDOWN:
                if event.key == pygame.K_q:
                    running = False

        snake = []
        blocks = []
        parts = line.split('|')
        score = parts[-1].strip()
        grid = parts[:-1]
        for y in range(len(grid)):
            row = grid[y]
            for x in range(len(row)):
                c = grid[y][x]
                if c == '#':
                    blocks.append([x,y])
                elif c == 'F':
                    foodx = x
                    foody = y
                elif c == '@':
                    snake.append([x,y])
                elif c == 'H':
                    headx = x
                    heady = y


        dis.fill(COLOR_BACKGROUND)
    
        pygame.draw.circle(
            dis, 
            COLOR_FOOD, 
            center=[foodx * BLOCK_SIZE + BLOCK_SIZE/2, foody * BLOCK_SIZE + BLOCK_SIZE/2], 
            radius=BLOCK_SIZE_FOOD//2
            )

        for x, y in blocks:
            pygame.draw.rect(dis, COLOR_BLOCK, [x * BLOCK_SIZE, y * BLOCK_SIZE, BLOCK_SIZE_SNAKE, BLOCK_SIZE_SNAKE])
 
        for x, y in snake:
            pygame.draw.rect(dis, COLOR_SNAKE, [x * BLOCK_SIZE, y * BLOCK_SIZE, BLOCK_SIZE_SNAKE, BLOCK_SIZE_SNAKE])
 
        pygame.draw.rect(dis, COLOR_HEAD, [headx * BLOCK_SIZE, heady * BLOCK_SIZE, BLOCK_SIZE_SNAKE, BLOCK_SIZE_SNAKE])

        value = FONT.render("Score: " + str(score), True, COLOR_SCORE)
        dis.blit(value, [10, 10])
 
        pygame.display.update()

        # `tobytes` in newer pygame would be nicer
        img = pygame.image.tostring(dis, 'RGB')
        imgs.append(img)

        if not running:
            break

        clock.tick(args.speed)


    img = Image.frombytes("RGB", (SCREEN_W, SCREEN_H), imgs[0])
    rest = [Image.frombytes("RGB", (SCREEN_W, SCREEN_H), img) for img in imgs[1:]]
    img.save(str(args.input.with_suffix(".gif").resolve()), format="GIF", append_images=rest, save_all=True, 
        duration=args.duration, 
        loop=0
    )

    pygame.quit()
 

if __name__ == '__main__':
    args = parser.parse_args()
    main(args)
