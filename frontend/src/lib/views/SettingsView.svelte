<script lang="ts">
    import { ChevronLeft } from "@lucide/svelte";

    import IconButton from "$components/app/IconButton.svelte";

    import { viewState } from "./view.svelte";
</script>

<IconButton placement="left" icon={ChevronLeft} action={() => viewState.setView("editor")} />
