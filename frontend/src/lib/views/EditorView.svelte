<script lang="ts">
    import { Settings2 } from "@lucide/svelte";
    import { shortcutAttach } from "$modules/shortcut";

    import DirtyIndicator from "$features/editor/components/DirtyIndicator.svelte";
    import Editor from "$features/editor/components/Editor.svelte";
    import Tabs from "$features/editor/components/Tabs.svelte";
    import { editorState } from "$features/editor/editorState.svelte";

    import IconButton from "$components/app/IconButton.svelte";

    import { viewState } from "./view.svelte";
</script>

<div
    class="mx-auto py-8 flex flex-col gap-5 h-full max-w-6xl w-full"
    {@attach shortcutAttach(
        [
            { combo: "Alt+N", action: () => editorState.addTab() },
            {
                combo: "Alt+W",
                action: () => {
                    if (editorState.activeNote?.id) {
                        editorState.removeTab(editorState.activeNote.id);
                    }
                },
            },
            ...Array.from({ length: 9 }, (_, i) => ({
                combo: `Alt+${i + 1}`,
                action: () => {
                    const note = editorState.notes[i];
                    if (note) {
                        editorState.setActiveNote(note.id);
                    }
                },
            })),
        ],
        { allowInInput: true }
    )}
>
    <Tabs />

    <Editor />

    <DirtyIndicator />

    <IconButton placement="right" icon={Settings2} action={() => viewState.setView("settings")} />
</div>
