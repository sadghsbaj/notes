<script lang="ts">
    import { Plus, X } from "@lucide/svelte";

    import { tabs, type Tab } from "./mock";
</script>

<div class="flex gap-3 w-full">
    <div class="p-1 flex gap-2 min-w-0 overflow-x-auto">
        {#each tabs as tab (tab.id)}
            {@render Tab(tab)}
        {/each}
    </div>

    <div class="p-1 shrink-0">
        {@render addTabButton()}
    </div>
</div>

{#snippet Tab(tab: Tab)}
    <div
        class="text-sm text-main font-500 px-3 rounded-full bg-elevation-1 flex gap-1 h-8 max-w-144px min-w-96px w-fit cursor-pointer shadow-sm items-center justify-between squircle-smooth hover:(shadow-md) active:(scale-95) t:(scale-200-quad-out shadow-200-quad-out)"
    >
        <span class="select-none truncate">
            {tab.title}
        </span>

        <button
            class="shrink-0 hover:(text-danger-500 scale-110) t:(scale-200-quad-out text-200-quad-out)"
        >
            <X size={16} strokeWidth={2.25} />
        </button>
    </div>
{/snippet}

{#snippet addTabButton()}
    <button
        class="text-main rounded-full bg-elevation-1 flex h-8 w-8 shadow-sm items-center justify-center squircle-smooth hover:(text-strong shadow-md) active:(scale-90) t:(scale-200-quad-out shadow-200-quad-out text-200-quad-out)"
    >
        <Plus size={20} strokeWidth={2.25} />
    </button>
{/snippet}
