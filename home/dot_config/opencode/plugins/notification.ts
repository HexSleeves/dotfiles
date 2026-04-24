import type { Plugin } from "@opencode-ai/plugin"

const platform = (globalThis as { process?: { platform?: string } }).process?.platform

export const NotificationPlugin: Plugin = async ({ project, client, $, directory, worktree }) => {
  const sendNotification = async () => {
    if (platform === "darwin") {
      await $`osascript -e 'display notification "Session completed!" with title "opencode"'`
      return
    }

    if (platform === "linux") {
      await $`notify-send "opencode" "Session completed!"`
      return
    }

    await $`printf '\a'`
  }

  return {
    event: async ({ event }) => {
      if (event.type === "session.idle") {
        try {
          await sendNotification()
        } catch (err) {
          console.warn("Failed to send completion notification:", err)
        }
      }
    },
  }
}
