# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: gscarama <gscarama@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2023/03/27 16:06:03 by samunyan          #+#    #+#              #
#    Updated: 2023/06/01 14:11:58 by gscarama         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

## Executable
NAME		=	miniRT

## System
SYSTEM		 := $(shell uname)

## Libraries
# Ft
FT_DIR		=	libs/libft/
LIBS		=	ft
# Mlx
ifeq ($(SYSTEM),Linux)
MLX_DIR		=	libs/libmlx/minilibx-linux/
LIBS		+=	mlx m X11 Xext bsd
else
MLX_DIR		=	libs/libmlx/minilibx_mms_20200219/
LIBS		+=	m mlx
endif
# Library paths
LIB_PATHS	=	$(FT_DIR) $(MLX_DIR)

## Project files
# Directories
SRCS_DIR	=	srcs/
INCL_DIR	=	includes/
INCL_PATHS	=	$(INCL_DIR) $(FT_DIR) $(MLX_DIR)
# Files
SRCS		=	camera.c \
				error.c \
				gmath.c \
				light.c \
				main.c \
				parse_material.c \
				object.c \
				parse_camera.c \
				parse_cylinder.c \
				parse_light.c \
				parse_plane.c \
				parse_sphere.c \
				parsing.c \
				parsing_checks.c \
				parsing_utils.c \
				parsing_valid.c \
				scene.c \
				image.c \
				hook.c \
				rgb_pixel.c\
				vector.c\
				vectors_op.c \
				ray.c \
				shade.c \
				hit_sphere.c \
				hit_plane.c \
				hit_cylinder.c

B_SRCS		=	camera.c \
				error.c \
				gmath.c \
				light.c \
				main.c \
				parse_material.c \
				object.c \
				parse_camera.c \
				parse_cylinder.c \
				parse_light.c \
				parse_plane.c \
				parse_sphere.c \
				parsing.c \
				parsing_checks.c \
				parsing_utils.c \
				parsing_valid_bonus.c \
				scene.c \
				image.c \
				hook.c \
				rgb_pixel.c\
				vector.c\
				vectors_op.c \
				ray.c \
				shade_bonus.c \
				hit_sphere.c \
				hit_plane.c \
				hit_cylinder.c

HEADERS		=	camera.h \
				error.h \
				gmath.h \
				light.h \
				material.h \
				minirt.h \
				object.h \
				parsing.h \
				scene.h \
				image.h \
				hook.h \
				rgb_pixel.h \
				ray.h \
				shade.h

OBJS		=	$(SRCS:.c=.o)
B_OBJS		=	$(B_SRCS:.c=.o)

## Compiler flags
ifeq ($(SYSTEM),Linux)
CC			=	clang
else
CC			= 	gcc
endif
CFLAGS		=	-Wall -Werror -Wextra
CPPFLAGS	=	$(foreach incl_path, $(INCL_PATHS), -I $(incl_path))
LDFLAGS		=	$(foreach lib_path, $(LIB_PATHS), -L $(lib_path)) $(foreach lib, $(LIBS), -l $(lib))

## Debug build settings
### Usage: make debug FLAGS="-g -fsanitize=address"
DBGDIR = debug/
DBGEXE = $(DBGDIR)$(NAME)
DBGCFLAGS = $(CFLAGS) $(FLAGS)
ifneq ($(BONUS_DEBUG), 1)
DBGOBJS = $(addprefix $(DBGDIR), $(OBJS))
else
DBGOBJS = $(addprefix $(DBGDIR), $(B_OBJS))
endif

## Release build settings
RELDIR =
RELEXE = $(RELDIR)$(NAME)
RELCFLAGS = $(CFLAGS)
ifneq ($(BONUS), 1)
RELOBJS = $(addprefix $(RELDIR), $(OBJS))
else
RELOBJS = $(addprefix $(RELDIR), $(B_OBJS))
endif

.PHONY:		all release clean fclean re debug prep build_libs

## Default build
all:		release

## Build libraries
build_libs:
			@$(foreach lib_path, $(LIB_PATHS), make -C $(lib_path) -s;)
ifeq ($(SYSTEM),Darwin)
	@cp $(MLX_DIR)libmlx.dylib libmlx.dylib
endif

## Release rules
release:	$(RELEXE)

bonus:
			@BONUS=1 make

$(RELEXE):	$(RELOBJS) build_libs
			@$(CC) $(RELCFLAGS) $(RELOBJS) $(LDFLAGS) -o $@
			@test -z '$(filter %.o,$?)' || echo $(BGreen)√$(Color_Off)$(BBlue)Compilation done.$(Color_Off)
			@echo $(BBlue)Usage:$(BGreen)$(UGreen)./$(RELEXE) "<*.rt>"$(Color_Off);

%.o: $(SRCS_DIR)%.c
			@$(CC) $(DBGCFLAGS) $(CPPFLAGS) -c $< -o $@

## Debug rules
debug:		prep $(DBGEXE)

bonus_debug:
				@BONUS_DEBUG=1 make

$(DBGEXE):	$(DBGOBJS) build_libs
			@echo $(BYellow)Debugging with following flags: $(FLAGS)$(Color_Off);
			@$(CC) $(DBGCFLAGS) $(DBGOBJS) $(LDFLAGS) -o $@
			@test -z '$(filter %.o,$?)' || echo $(BGreen)√$(Color_Off)$(BBlue)Compilation done.$(Color_Off)
			@echo $(BBlue)Usage:$(BGreen)$(UGreen)./$(DBGEXE) "<*.rt>"$(Color_Off);

$(DBGDIR)%.o: $(SRCS_DIR)%.c
			@$(CC) $(DBGCFLAGS) $(CPPFLAGS) -c $< -o $@

## Other rules
prep:
			@mkdir -p $(DBGDIR)

clean:
			@rm -f $(RELOBJS) $(DBGOBJS) $(addprefix $(RELDIR), $(B_OBJS)) $(addprefix $(DBGDIR), $(B_OBJS))
			@rm -rf $(DBGDIR)
			@$(foreach lib_path, $(LIB_PATHS), make -C $(lib_path) clean -s;)
			@echo $(BGreen)√$(Color_Off)$(BBlue)Object files removed.$(Color_Off);

fclean:		clean
			@rm -f $(RELEXE) $(DBGEXE)
			@rm -f libmlx.dylib
			@make -C $(FT_DIR) fclean -s
			@echo $(BGreen)√$(Color_Off)$(BBlue)Executable removed.$(Color_Off);

re:			fclean all

## Colors
# Reset
Color_Off='\033[0m'       # Text Reset
# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White
# Bold
BBlack='\033[1;30m'       # Black
BRed='\033[1;31m'         # Red
BGreen='\033[1;32m'       # Green
BYellow='\033[1;33m'      # Yellow
BBlue='\033[1;34m'        # Blue
BPurple='\033[1;35m'      # Purple
BCyan='\033[1;36m'        # Cyan
BWhite='\033[1;37m'       # White
## Underline
UBlack='\033[4;30m'       # Black
URed='\033[4;31m'         # Red
UGreen='\033[4;32m'       # Green
UYellow='\033[4;33m'      # Yellow
UBlue='\033[4;34m'        # Blue
UPurple='\033[4;35m'      # Purple
UCyan='\033[4;36m'        # Cyan
UWhite='\033[4;37m'       # White
# Background
On_Black='\033[40m'       # Black
On_Red='\033[41m'         # Red
On_Green='\033[42m'       # Green
On_Yellow='\033[43m'      # Yellow
On_Blue='\033[44m'        # Blue
On_Purple='\033[45m'      # Purple
On_Cyan='\033[46m'        # Cyan
On_White='\033[47m'       # White
# Bold High Intensity
BIBlack='\033[1;90m'      # Black
BIRed='\033[1;91m'        # Red
BIGreen='\033[1;92m'      # Green
BIYellow='\033[1;93m'     # Yellow
BIBlue='\033[1;94m'       # Blue