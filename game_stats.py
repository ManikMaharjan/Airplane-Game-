class GameStats:
    """Track statistic for alien Invasion"""
    def __init__(self,ai_game):
        "Intitalize Statistic"
        self.settings =ai_game.settings
        self.reset_stats()
        #starting Alien invasion in an actice state
        self.game_active = False
        #High score should nver be reset
        self.high_score= 1
    

    def reset_stats(self):
        """Initialize statistic that can change during the game ."""
        self.ship_left=self.settings.ship_limit
        self.score = 0     
        self.level =1   
        
         