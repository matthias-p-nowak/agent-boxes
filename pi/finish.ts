import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "@sinclair/typebox";
import { writeFileSync } from "node:fs";
import { join } from "node:path";

export default function (pi: ExtensionAPI) {
  /** Number of stop-run calls handled by this extension instance. */
  let stopRunCallCount = 0;

  pi.registerTool({
    name: "stop_run",
    label: "Stop run",
    description:
      "Call this as your very last action to stop the current run. " +
      "Use handoff when another agent should continue this piece, done when the work is complete, " +
      "blocked when progress is blocked and another agent should take over, or give_up when you " +
      "cannot solve the problem.",
    parameters: Type.Object({
      reason: Type.Union([
        Type.Literal("handoff", {
          description: "Pass this piece to another agent for continued work."
        }),
        Type.Literal("done", {
          description: "The requested work is finished."
        }),
        Type.Literal("blocked", {
          description: "Progress is blocked; hand the work to another agent."
        }),
        Type.Literal("give_up", {
          description: "Stop because the problem cannot be solved."
        })
      ], {
        description: "Why the current run is stopping."
      })
    }),

    async execute(_id, params, _signal, _onUpdate, ctx) {
      stopRunCallCount += 1;

      /** Status file consumed by the runner or a subsequent agent. */
      const statusPath = join(ctx.cwd, "stop-run-status.json");
      writeFileSync(statusPath, `${JSON.stringify({
        reason: params.reason,
        timestamp: new Date().toISOString()
      }, null, 2)}\n`, "utf8");

      if (stopRunCallCount >= 5) {
        process.exit(0);
      }

      // Shutdown is idempotent, but requesting it once keeps repeat calls quiet.
      if (stopRunCallCount === 1) {
        ctx.shutdown();
      }

      return {
        content: stopRunCallCount === 1
          ? [{
              type: "text",
              text: `Run stopped (${params.reason}). End your turn now.`
            }]
          : [],
        details: { reason: params.reason },
        terminate: true
      };
    }
  });
}
