<script lang="ts">
    import { Plus, X } from "@lucide/svelte";

    import { editorState, type Note } from "$features/editorState.svelte";
</script>

<div class="flex gap-3 w-full">
    <div class="p-1 flex gap-2 min-w-0 overflow-x-auto">
        {#each editorState.notes as tab (tab.id)}
            {@render Tab(tab)}
        {/each}
    </div>

    <div class="p-1 shrink-0">
        {@render addTabButton()}
    </div>
</div>

{#snippet Tab(tab: Note)}
    <button
        onclick={() => editorState.setActiveNote(tab.id)}
        class="text-sm font-500 px-3 rounded-full flex gap-1 h-8 max-w-144px min-w-96px w-fit cursor-pointer shadow-sm items-center justify-between squircle-smooth hover:(shadow-md) active:scale-95 t:(bg-200-quad-out scale-200-quad-out shadow-200-quad-out text-200-quad-out) {tab ===
        editorState.activeNote
            ? 'text-white bg-zinc-800 dark:text-zinc-950 dark:bg-zinc-200'
            : 'text-main bg-elevation-1'}"
    >
        <span class="min-w-0 select-none truncate">{tab.title}</span>

        <span
            tabindex="0"
            role="button"
            onclick={(e) => {
                e.stopPropagation();
                editorState.removeTab(tab.id);
            }}
            onkeydown={(e) => {
                if (!(e.key === "Enter" || e.key === " ")) {
                    return;
                }

                e.stopPropagation();
                editorState.removeTab(tab.id);
            }}
            class="shrink-0 hover:(text-danger-500 scale-110) t:(scale-200-quad-out text-200-quad-out)"
        >
            <X size={16} strokeWidth={2.25} />
        </span>
    </button>
{/snippet}

{#snippet addTabButton()}
    <button
        onclick={() => editorState.addTab()}
        class="text-main rounded-full bg-elevation-1 flex h-8 w-8 shadow-sm items-center justify-center squircle-smooth hover:(text-strong shadow-md) active:(scale-90) t:(scale-200-quad-out shadow-200-quad-out text-200-quad-out)"
    >
        <Plus size={20} strokeWidth={2.25} />
    </button>
{/snippet}
