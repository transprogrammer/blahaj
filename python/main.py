#!/usr/bin/env python3

# REQ: Creates HTML5 color roles. <skr 2023-02-11>

# ???: What roles and permissions are needed? <skr>

# TODO: Parameterize sync_roles() instead of named commands. <skr>

# TODO: Unit test with pytest. <skr 2023-02-11>

from disnake import Intents
from disnake import Game
from discord import Colour
from disnake.ext.commands import Bot
from os import environ
from webcolors import CSS3_NAMES_TO_HEX
import csv

GSRM_PATH = "../config/gsrm.csv"

PREFIX = "!"

INTENTS = Intents.default()
INTENTS.message_content = True

GAME = Game(name="musical notes 🎶")

BOT = Bot(command_prefix=PREFIX, intents=INTENTS, activity=GAME)


@BOT.command()
async def sync_colour_roles(context):
    sync_roles(
        context,
        get_color_names(),
        handle_color_role_color
    )


@BOT.command()
async def sync_gsrm_roles(context):
    sync_roles(
        context,
        get_gsrm_names(),
        handle_gsrm_role_color
    )


def get_color_names():
    return CSS3_NAMES_TO_HEX.keys()


def get_gsrm_names():
    data = []
    with open(GSRM_PATH, 'r') as file:
        reader = csv.reader(file)
        for row in reader:
            data.append(row)
    return data


def handle_color_role_color(name):
    hex_color = CSS3_NAMES_TO_HEX[name]
    return Colour.from_str(hex_color)


def handle_gsrm_role_color(name):
    return Colour.random()


# NOTE: Intentionally segmented. <skr 2023-02-11>
def sync_roles(names, context):
    roles = get_roles(names, context)

    remove_duplicates(roles, context)
    remove_unlisted(roles, context)
    create_missing(roles, context)


def get_roles(roles_names, context):
    return [role for role in context.guild.roles if role.name in roles_names]


def remove_duplicates(roles, context):
    await context.send("Removing duplicates...")

    existent_roles = set()
    duplicate_roles = list()

    for role in roles:
        if role in existent_roles:
            duplicate_roles.append(role)
        else:
            existent_roles.add(role)

        for role in duplicate_roles:
            await role.delete()


def remove_unlisted(roles, context):
    await context.send("Removing unlisted...")

    for role in roles:
        if role.name not in roles:
            await role.delete()

def main():
    TOKEN = environ["DISCORD_TOKEN"]

    BOT.run(TOKEN)


main
