/**
 * cmux notification plugin for OpenCode
 *
 * Sends a cmux notification ring when OpenCode goes idle (waiting for input)
 * or encounters an error. Requires cmux to be running.
 *
 * https://cmux.dev/docs/notifications
 */

export const CmuxNotifyPlugin = async ({ $ }) => {
  // Skip if not running inside cmux
  const inCmux = await $`test -S /tmp/cmux.sock`.quiet().then(() => true).catch(() => false)
  if (!inCmux) return {}

  return {
    event: async ({ event }) => {
      if (event.type === "session.idle") {
        await $`cmux notify --title "OpenCode" --body "Waiting for your input"`.quiet().catch(() => {})
      }

      if (event.type === "session.error") {
        const msg = event.properties?.message ?? "An error occurred"
        await $`cmux notify --title "OpenCode Error" --body ${msg}`.quiet().catch(() => {})
      }
    },
  }
}
