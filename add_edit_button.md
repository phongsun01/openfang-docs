# Add Edit Button to Agent Chips

Currently, the OpenFang Dashboard allows clicking agent chips to start a chat, but there is no obvious way to modify an existing agent's configuration (like changing its model or system prompt). This feature adds an "Edit" button to each agent card.

## Implementation Details

### Dashboard UI Changes

- **Pencil Icon**: Added a button with a pencil icon to the `.agent-chip` component in `index_body.html`.
- **Event Handling**: The button uses `@click.stop="showDetail(agent)"` to open the agent detail modal without triggering the parent click event (which would open the chat view).
- **Styling**: The button is styled as a ghost button with a circular hover effect, positioned to the right of the agent icon and name.

```html
<button class="btn btn-ghost btn-sm" 
        @click.stop="showDetail(agent)" 
        title="Edit Agent" 
        style="padding: 4px; border-radius: 50%; width: 28px; height: 28px; display: flex; align-items: center; justify-content: center; margin-left: auto;">
  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
    <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7" />
    <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z" />
  </svg>
</button>
```

## How to Use

1.  Open the OpenFang Dashboard (`http://127.0.0.1:4200/#agents`).
2.  Locate the agent you want to modify in the **Your Agents** section.
3.  Click the **Pencil Icon** on the right side of the agent chip.
4.  In the modal that appears, switch to the **Config** tab.
5.  Modify the model name, provider, or system prompt.
6.  Click **Save Config**.
7.  The changes will be applied to the `agent.toml` file on disk and reflected in the UI.
