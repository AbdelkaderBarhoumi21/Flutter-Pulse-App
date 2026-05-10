# Pulse

A Flutter task management app with real-time push notifications.

## Overview

Pulse is the mobile client for the `task_api` Rust backend. It lets you create, update, and track tasks, and receives push notifications via Firebase Cloud Messaging when tasks change.

## Features

- 📋 Full task CRUD (create, read, update, delete)
- 🔔 Real-time push notifications (FCM)
- 🎯 Deep linking from notifications to specific task screens
- 📱 Foreground & background notification handling
- 🎨 Custom notification icons (status bar + in-app)

## Tech Stack

- **Flutter** — UI framework
- **Riverpod** — State management & dependency injection
- **GoRouter** — Declarative navigation with deep-link support
- **Dio** — HTTP client
- **Firebase Cloud Messaging** — Remote push notifications
- **flutter_local_notifications** — Foreground notification banners

## Architecture

Clean Architecture with MVVM:
