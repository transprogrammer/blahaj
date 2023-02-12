#!/usr/bin/env python3

# REQ: Creates HTML5 color roles. <skr 2023-02-11>

# ???: What scopes and permissions are needed? <skr>

from disnake import Intents
from disnake import Game
from discord import Colour
from disnake.ext.commands import Bot
from os import environ
from webcolors import CSS3_NAMES_TO_HEX

PREFIX = '!'

INTENTS = Intents.default()
INTENTS.message_content = True

GAME= Game(name="musical notes 🎶")

BOT = Bot(command_prefix=PREFIX, intents=INTENTS, activity=GAME)

@BOT.command()
async def colour_sync(context):
    print(context)
    for name, hex in CSS3_NAMES_TO_HEX.items(): 
        hex_color = Colour.from_str(hex)

        role_opts = {
          'name': name,
          'color': hex_color,
        }

        await context.send(f'{name}:{hex}')
        await context.guild.create_role(**role_opts)

@BOT.command()
async def colour_sync(context):
    print(context)

    for role in desired_roles:
        await context.send(f'{name}')


def desired_roles
    with open('../config/gsrm.csv', 'r') as csvfile:
        role_reader = csv.reader(csvfile)
        desired_roles = [row[0] for row in role_reader]

TOKEN = environ['DISCORD_TOKEN']

BOT.run(TOKEN)
