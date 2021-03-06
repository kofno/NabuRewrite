module Main where

import Task
import Effects
import StartApp

import Nabu.Model  as Nabu
import Nabu.Update as Nabu
import Nabu.View   as Nabu

app : StartApp.App Nabu.Model
app = StartApp.start
        { init   = Nabu.init
        , view   = Nabu.view
        , update = Nabu.update
        , inputs = []
        }

main = app.html

port tasks : Signal (Task.Task Effects.Never ())
port tasks = app.tasks
