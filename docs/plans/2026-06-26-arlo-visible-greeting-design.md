# Arlo Visible Greeting Design

Status: Completed

## Problem

`viewDidLoad` starts synthesized speech even though UIKit may load a controller
before it is onscreen. A preloaded or abandoned controller can therefore emit
the Arlo greeting without visible user context.

## Options

1. Keep greeting ownership in `viewDidLoad`; hidden-view speech remains possible.
2. Speak on every `viewDidAppear`; returning to the controller repeats the launch greeting.
3. Claim one-time greeting ownership in `viewDidAppear` only while the controller is active.

## Decision

Use option 3. Preserve the existing greeting and recording interruption while
requiring active visibility and one-time ownership before speech begins.
