<script lang="ts">
    import type { Component } from "svelte";
    import { ChevronLeft, Monitor, Moon, Sparkles, Sun, ZapOff } from "@lucide/svelte";

    import { motionPreference, theme, type MotionPreference, type ThemeMode } from "$core/_system";

    import IconButton from "$components/app/IconButton.svelte";

    import { viewState } from "./view.svelte";

    interface Option<T> {
        label: string;
        value: T;
        icon: Component;
    }

    const themeOptions: Option<ThemeMode>[] = [
        { label: "System", value: "system", icon: Monitor },
        { label: "Light", value: "light", icon: Sun },
        { label: "Dark", value: "dark", icon: Moon },
    ];

    const motionOptions: Option<MotionPreference>[] = [
        { label: "System", value: "system", icon: Monitor },
        { label: "Full Motion", value: "no-preference", icon: Sparkles },
        { label: "Reduced", value: "reduce", icon: ZapOff },
    ];
</script>

<div class="mx-auto py-12 flex flex-col gap-5 h-full max-w-6xl w-full">
    <h2 class="text-3xl text-main font-700">Settings</h2>

    <div class="p-4 rounded-2xl bg-elevation-1 flex flex-col gap-3 shadow-sm squircle-smooth">
        <h3 class="text-sm text-weak tracking-wide font-600 uppercase">Theme</h3>

        <div class="flex flex-wrap gap-3">
            {#each themeOptions as option (option.value)}
                {const Icon = option.icon}
                <button
                    onclick={() => theme.set(option.value)}
                    class="text-sm font-600 rounded-full flex gap-2 h-36px w-144px cursor-pointer items-center justify-center squircle-smooth active:scale-95 t:(bg-150-quad-out scale-150-cubic-out shadow-150-quad-out text-150-quad-out) {theme.mode ===
                    option.value
                        ? 'text-strong bg-elevation-2 shadow-sm'
                        : 'text-weak bg-transparent hover:(text-main bg-elevation-2/50)'}"
                >
                    <Icon size={16} strokeWidth={2.25} />
                    <span>{option.label}</span>
                </button>
            {/each}
        </div>
    </div>

    <div class="p-4 rounded-2xl bg-elevation-1 flex flex-col gap-3 shadow-sm squircle-smooth">
        <h3 class="text-sm text-weak tracking-wide font-600 uppercase">Motion</h3>

        <div class="flex flex-wrap gap-3">
            {#each motionOptions as option (option.value)}
                {const Icon = option.icon}
                <button
                    onclick={() => motionPreference.set(option.value)}
                    class="text-sm font-600 rounded-full flex gap-2 h-36px w-144px cursor-pointer items-center justify-center squircle-smooth active:scale-95 t:(bg-150-quad-out scale-150-cubic-out shadow-150-quad-out text-150-quad-out) {motionPreference.preference ===
                    option.value
                        ? 'text-strong bg-elevation-2 shadow-sm'
                        : 'text-weak bg-transparent hover:(text-main bg-elevation-2/50)'}"
                >
                    <Icon size={16} strokeWidth={2.25} />
                    <span>{option.label}</span>
                </button>
            {/each}
        </div>
    </div>
</div>

<IconButton placement="left" icon={ChevronLeft} action={() => viewState.setView("editor")} />


