<script lang="ts">
    import { FileText } from "@lucide/svelte";

    import { focusAttach } from "$core/_system/focus/focus.attach";
    import { editorState } from "$features/editor/editorState.svelte";
</script>

<div class="p-1 flex-1 overflow-hidden">
    {#if editorState.activeNote}
        <div class="flex flex-col gap-3 h-full w-full">
            <input
                class="text-md text-main px-3 rounded-full bg-elevation-1 flex h-40px w-fit shadow-sm items-center squircle-smooth"
                value={editorState.activeNote.title}
                oninput={(e) => editorState.updateActiveNote({ title: e.currentTarget.value })}
            />

            <textarea
                class="text-md p-8 rounded-3xl bg-elevation-1 flex-1 resize-none shadow-sm squircle-smooth placeholder-text-weak focus:(outline-none)"
                placeholder="Content..."
                value={editorState.activeNote.content}
                oninput={(e) => editorState.updateActiveNote({ content: e.currentTarget.value })}
                {@attach focusAttach({ enabled: false })}></textarea>
        </div>
    {:else}
        <div class="flex-center h-full w-full">
            <div
                class="text-md text-main font-600 p-12 rounded-full bg-elevation-1 flex-center flex-col gap-3 shadow-sm squircle-smooth"
            >
                <FileText size={32} strokeWidth={2.5} />
                No note selected
            </div>
        </div>
    {/if}
</div>
