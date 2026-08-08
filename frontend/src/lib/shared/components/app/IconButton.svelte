<script lang="ts">
    import type { Component } from "svelte";

    interface Props {
        placement: "left" | "right";
        icon: Component;
        action: () => void;
    }

    let { placement, icon, action }: Props = $props();
</script>

<button
    onclick={action}
    class="{placement === 'left'
        ? 'left-6'
        : 'right-6'} rounded-full bg-elevation-1 flex-center h-9 w-9 shadow-sm top-8 fixed squircle-smooth hover:(shadow-md) active:(scale-90) t:(scale-200-cubic-out shadow-200-quad-out)"
>
    {const Icon = icon}
    <Icon size={20} strokeWidth={2.5} />
</button>
