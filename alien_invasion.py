import sys
from time import sleep
import pygame
from setting import Settings
from ship import Ship
from bullet import Bullet
from alien import Alien
from game_stats import GameStats
from button import Button
class AlienInvasion:
    """Overall class to manage game asset and behaviour"""
    def __init__(self):
        """Intialize the game, and create game resource"""
        pygame.init()
        self.settings=Settings()
        self.screen=pygame.display.set_mode((0,0),pygame.FULLSCREEN)
        self.settings.screen_width = self.screen.get_rect().width
        self.settings.screen_height=self.screen.get_rect().height
        
        pygame.display.set_caption('Alien Invasion')
        # self.bg_color = (230,230,230)#set of RGB
        # self.settings =Settings()
        # self.screen =pygame.display.set_mode(
        #   (self.settings.screen_width,self.settings.screen_height)  
        # )
        self.ship=Ship(self)
        self.bullets=pygame.sprite.Group()
        self.aliens=pygame.sprite.Group()
        self._create_fleet()
        #create an instance to store game statistic
        self.stats=GameStats(self)
        #Make the play button
        self.play_button = Button(self,"Play")
     
    def run_game(self):
        """Start the main loop for the game"""
        while True:
                     
            self._check_events()
            if self.stats.game_active:
    
                    self.ship.update()
                    self._update_screen()   
                    self.bullets.update()
                    self. _update_bullets()
                    self. _update_aliens()

       
            
    def _check_events(self):
       # "Responding to keypress and mouse events"
        for event in pygame.event.get():
                if event.type ==pygame.QUIT:
                    sys.exit()  
                elif event.type == pygame.KEYDOWN:
                    self._check_keydown_events(event)
                    
                elif event.type ==pygame.KEYUP:
                    self._check_keyup_events(event)
                   
                     
    def _check_keydown_events(self,event):
        """Respond to keypress."""
        if event.key ==pygame.K_RIGHT:
            self.ship.moving_right =True
                #self.ship.rect.x +=10
        elif event.key ==pygame.K_LEFT:
            self.ship.moving_left =True
        elif event.key ==pygame.K_q:
            sys.exit()
            ##adding the fire key 
        elif event.key ==pygame.K_SPACE:
            self._fire_bullet()
            #move the ship to right.
             # self.ship.rect.x -=10
    
    def _check_keyup_events(self,event):
        if event.key ==pygame.K_RIGHT:
             self.ship.moving_right=False
        elif event.key ==pygame.K_LEFT:
            self.ship.moving_left =False
        
    def _fire_bullet(self):
        "Create a new bullet and add it to the bullets group"
        if len(self.bullets) < self.settings.bullets_allowed:
            new_bullet =Bullet(self)
            self.bullets.add(new_bullet)
            
    def _update_bullets(self):
        "Update position of bullets and get rid of old wallet"
        #update bullet position.
        #Sprite.groupcollide() function compares the rects of each element
        self.bullets.update()
        #Getting rid of bullet that have disappeared
        for bullet in self.bullets.copy():
                if bullet.rect.bottom <=0:
                    self.bullets.remove(bullet)
        #look for alien-ship collisions.
        if pygame.sprite.spritecollideany(self.ship,self.aliens):
            print("ship hit!!!")            
        
        
        self._check_bullet_allien_collision()
        
    
    def _check_bullet_allien_collision(self):
    #check for any bullet that hit alients.
        #if so, get rid of the bullet and the alien
        collisions=pygame.sprite.groupcollide(
            self.bullets,self.aliens,True,True
        )  
        if not self.aliens:
            #destory exisitng bullet and create new fleet.
            self.bullets.empty()
            self._create_fleet()          
        print(len(self.bullets))
        
                 
            
    
    def _update_screen(self):
        """Update  image on the screen and flip to the new screen"""
        self.screen.fill(self.settings.bg_color) # color using the fill method
        self.ship.blitme()
        for bullet in self.bullets.sprites():
            bullet.draw_bullet()
           # Make the most recently drawn screen visiibe.
        
        #alien 
        self.aliens.draw(self.screen)
        ###Draw the plat button if the game is inactive
        if not self.stats.game_active:
            self.play_button.draw_button()
        
        ####
        pygame.display.flip()  
        
    def _create_fleet(self):
        """Create the fleet of aliens."""
        ##Spacing between each alien is equal to one alien width
        #make an alien.
        alien=Alien(self)
        alien_width,alien_height= alien.rect.size
        availabe_space_x =self.settings.screen_width - (2 * alien_width)
        number_aliens_x= availabe_space_x // (2 * alien_width)
        
        #Determine the number of rows of aliens that fit on the screen.
        ship_height =self.ship.rect.height
        availabe_space_y=(self.settings.screen_height -(8 * alien_height
                                                        )-ship_height)
        number_rows =availabe_space_y // (2 *alien_height)
        
        #create the full fleet of aliens.
        for row_number in range(number_rows):
            for alien_number in  range(number_aliens_x):
                self ._create_alien( alien_number, row_number)
                
    def _create_alien(self,alien_number,row_number):
        """Creare an alien and place it in the row"""
        alien =Alien(self)
        alien_width,alien_height =alien.rect.size
        alien.x =alien_width + 2 * alien_width * alien_number
        alien.rect.x =alien.x
        alien.rect.y =alien.rect.height + 2 * alien.rect.height * row_number
        self.aliens.add(alien)
        
    def _check_fleet_edges(self):
        "Respond appropriately if any aliens have reached an edge"
        for alien in self.aliens.sprites():
            if alien.check_edges():
                self._check_fleet_direction()
                break
    
    
    def _check_fleet_direction(self):
        "Drop the entire fleet and change the fleet's direction"
        for alien in self.aliens.sprites():
            alien.rect.y += self.settings.fleet_drop_speed
        self.settings.fleet_direction *=-1
        
        
    def _update_aliens(self):
        
       """
       Check if the fleet is at an edge, then update the position of all
       then update the position of all the alien in the fleet.
       """ 
       self._check_fleet_edges()
       self.aliens.update()
       self._ship_hit()
       self._check_alien_botton()
    
    def _ship_hit(self):
        """Respond to the ship being hit by an alien"""
        #Decrement ships left.
        if self.stats.ship_left >0:
            
            self.stats.ship_left -=1
        
            #get rid of any remaining aliens and bullets
            self.aliens.empty()
            self.bullets.empty()
            
            #create a new fleet and center the ship
            self._create_fleet()
            self.ship.center_ship()
        
        #pause
            sleep(0.5)
        else:
            self.stats.game_active =True
        
    def _check_alien_botton(self):
        """check if any aliens have reached the bottom of the screen"""
        screen_rect = self.screen.get_rect()
        for alien in self.aliens.sprites():
            if alien.rect.bottom >=screen_rect.bottom:
                #treat this the same as if the ship got hit.
                self._ship_hit()
                break

    
if __name__== '__main__':
        #make a game instance , run the game
        ai= AlienInvasion()
        ai.run_game()
        #  page number 267