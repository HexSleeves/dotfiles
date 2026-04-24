import type { Plugin } from "@opencode-ai/plugin"

export const TerminalBell: Plugin = async ({ project, client, $, directory, worktree }) => {
  const platform = (globalThis as { process?: { platform?: string } }).process?.platform

  const playBell = async () => {
    if (platform === "darwin") {
      await $`afplay /System/Library/Sounds/Funk.aiff`
      return
    }

    if (platform === "linux") {
      try {
        await $`canberra-gtk-play -i bell`
        return
      } catch {}

      try {
        await $`paplay /usr/share/sounds/freedesktop/stereo/complete.oga`
        return
      } catch {}

      try {
        await $`pw-play /usr/share/sounds/freedesktop/stereo/complete.oga`
        return
      } catch {}

      try {
        await $`aplay /usr/share/sounds/alsa/Front_Center.wav`
        return
      } catch {}
    }

    await $`printf '\a'`
  }

  return {
    event: async ({ event }) => {
      if (event.type === "session.idle") {
        try {
          await playBell()
        } catch (err) {
          console.warn("Failed to play audible bell:", err)
        }
      }
    }
  }
}
