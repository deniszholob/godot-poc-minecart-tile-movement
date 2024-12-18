minecart obj

player obj


user input 'action'
    if player in cart get off
    if player near cart get on
    else do nothing

different players can be in different carts 
how to attach/detach user contro to different objects?


player
    movement_controller
    input_getter

minecart
    cart_controller
        input: movement vector
        output signal: position vector
    control_input_getter
        input: none
        output signal: movement vector

