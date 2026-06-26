# Arlo Greeting Capture Boundary Design

Status: Completed

## Problem

Arlo speaks a launch greeting and enables configured Wit voice capture in the
same controller. If recording starts while the synthesizer is still speaking,
app-generated speech can enter the microphone request and waveform, producing
self-capture and unintended provider input.

## Options

1. Leave speech and recording independent. This preserves self-capture risk.
2. Disable the microphone for the entire greeting. This changes interaction
   timing and requires additional button-state lifecycle synchronization.
3. Stop synthesized speech on the main queue immediately when Wit reports that
   recording started, before recording UI state activates.

## Decision

Use option 3 as the smallest compatible boundary for the legacy Wit button.
Keep the greeting, microphone control, accepted message flow, token behavior,
and teardown unchanged.

## Verification

The implementation plan requires red-first ordering coverage, hostile mutation
rejection, portable gates, hosted macOS checks, and explicit device limitations.
