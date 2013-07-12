module Constants
  module Shell
    RESET = "\e[0m"
    BOLD  = "\e[1m"
    UBOLD = "\e[21m"
    
    module Color
      DEFAULT  = "\e[39m"
      LRED     = "\e[91m"
      RED      = "\e[31m"
      LGREEN   = "\e[92m"
      GREEN    = "\e[32m"
      LYELLOW  = "\e[93m"
      YELLOW   = "\e[33m"
      LBLUE    = "\e[94m"
      BLUE     = "\e[34m"
      LMAGENTA = "\e[95m"
      MAGENTA  = "\e[35m"
      L_CYAN   = "\e[96m"
      CYAN     = "\e[36m"
      LGRAY    = "\e[37m"
      GRAY     = "\e[90m"
      WHITE    = "\e[97m"
    end
  end
  module Time
    MINUTE = 60
    HOUR = 60 * MINUTE
    DAY = 24 * HOUR
    WEEK = 7 * DAY
    MONTH = 4 * WEEK
    YEAR = 365 * DAY
  end
end

