<script lang="ts">
    import { Plus, X } from "@lucide/svelte";

    interface Tab {
        id: string;
        title: string;
    }

    const tabs: Tab[] = [
        {
            id: "1",
            title: "Test1",
        },
        {
            id: "2",
            title: "Test2",
        },
        {
            id: "3",
            title: "Test3",
        },
        {
            id: "4",
            title: "Test4",
        },
        {
            id: "5",
            title: "Test5",
        },
        {
            id: "6",
            title: "Test6",
        },
        {
            id: "7",
            title: "Test7",
        },
        {
            id: "8",
            title: "Test8",
        },
        {
            id: "9",
            title: "Test9",
        },
    ];
</script>

<div class="flex gap-2 w-full">
    {#each tabs as tab (tab.id)}
        {@render Tab(tab)}
    {/each}

    {@render addTabButton()}
</div>

{#snippet Tab(tab: Tab)}
    <div
        class="text-sm text-main font-500 px-3 rounded-full bg-elevation-1 flex gap-1 h-8 max-w-144px min-w-96px w-fit cursor-pointer shadow-sm items-center justify-between squircle-smooth hover:(shadow-md) active:(scale-95) t:(scale-200-quad-out shadow-200-quad-out)"
    >
        <span class="select-none truncate">
            {tab.title}
        </span>

        <button
            class="shrink-0 hover:(text-strong scale-110) t:(scale-200-quad-out text-200-quad-out)"
        >
            <X size={16} strokeWidth={2.25} />
        </button>
    </div>
{/snippet}

{#snippet addTabButton()}
    <button
        class="text-main rounded-full bg-elevation-1 flex h-8 w-8 shadow-sm items-center justify-center squircle-smooth hover:(text-strong shadow-md) active:(scale-93)"
    >
        <Plus size={20} strokeWidth={2.25} />
    </button>
{/snippet}
