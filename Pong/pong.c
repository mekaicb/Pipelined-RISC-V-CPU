#include <stdint.h>

#define WPR 40   // 640px / 16px-per-word -> 40 Words/Row

#define topLeft ((volatile uint32_t *)0x9B28)
#define topRight ((volatile uint32_t *)0x9B78)
#define bottomLeft ((volatile uint32_t *)0x13128)

#define RED 0x55555555
#define BLUE 0xFFFFFFFF
#define GREEN 0xAAAAAAAA
#define BLACK 0x00000000

#define p1_left ((volatile uint32_t *)0x17C00)
#define p1_right ((volatile uint32_t *)0x17C04)
#define p2_left ((volatile uint32_t *)0x17C08)
#define p2_right ((volatile uint32_t *)0x17C0C)

#define DELAY 400000

#define MAX_RIGHT ((volatile uint32_t *)0x12EF0) // Center position + 4(9) -> 9 words right of paddle center (9 since game area is 20 words, half from center is 10 words)
#define MAX_LEFT ((volatile uint32_t *)0x12EA8)


void draw_borders(void);
void draw_players(volatile uint32_t **p1_pos, volatile uint32_t *p1left, volatile uint32_t *p1right, volatile uint32_t *p2left, volatile uint32_t *p2right);
void fill_colour(volatile uint32_t color, volatile uint32_t **p1_pos); 
void delay(void);

void main(void){

    volatile uint32_t *p1 = (volatile uint32_t *)0x12ECC; // Bottom center
    volatile uint32_t *p1_pos = p1; // initilize position to center

    draw_borders();
    while(1){
	delay();
        draw_players(&p1_pos, p1_left, p1_right, p2_left, p2_right);
    }

    while(1);
}

void draw_borders(void){

    // Draw vertical borders
    for(int i = 0; i <= 240; i++){ // 240 vertical pixels
        topLeft[i * WPR]  = (BLUE & 0x3); // Only draw one pixel, zeroes out all except the last 2 bits
        topRight[i * WPR] = (BLUE & 0x3);
    }

    // Draw horizontal borders
    for(int i = 0; i < 20; i++){ // Each writes a full word, so only need 20x32 to write full row
        topLeft[i]    = 0xFFFFFFFF;
        bottomLeft[i] = 0xFFFFFFFF;
    }
}

void draw_players(volatile uint32_t **p1_pos, volatile uint32_t *p1left, volatile uint32_t *p1right, volatile uint32_t *p2left, volatile uint32_t *p2right){

    if(!(*p1left) && !(*p1right)){ // If no user input, maintain current position
        fill_colour(BLUE, p1_pos);
    }
    else if(*p1right){
        if(*p1_pos != MAX_RIGHT){
	    fill_colour(BLACK, p1_pos); // Clear the old player position
            *p1_pos += 1; // Advance one word
	}
        fill_colour(BLUE, p1_pos); // Draw the new player position
    }
    else if(*p1left){
        if(*p1_pos != MAX_LEFT){
            fill_colour(BLACK, p1_pos); // Clear the old player position
            *p1_pos -= 1; // Advance one word
        }
        fill_colour(BLUE, p1_pos); // Draw the new player position
    }

}

void delay(void){
    for(volatile int i = 0; i < DELAY; i++); // empty for loop to stall the program, set to volatile uint32_t so compiler doesnt delete empty for loop
}

void fill_colour(volatile uint32_t colour, volatile uint32_t **p1_pos){ // since p1_pos is not being written to, don't need a 2nd layer pass by ref
    for(int i = 0; i < 3; i++){
        for(int j = 0; j < 2; j++){
            (*p1_pos)[j - (i*WPR)] = colour; // Draw new position
        }
    }
}


/*
Top left calculation: (160,120) to (480, 120)
        = Addr 19240 to Addr 19320 (w/o fb offset) in bytes
        = 0x9B28 to 0x9B78 (w/fb offset), offset = 0x5000
To get 0x12ECC:
        Bottom center is 40 bytes + 0x13128 bytes. Draw player from 0x13128 + 36 to 0x13128 + 44 bytes.
        Subtract 16(WPR) to move it above center 16px = 0x12ECC
*/

