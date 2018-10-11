function Effect(f) {
    return {
        /**
         * m a ~> a
         */
        unsafeRun() {
            return f.apply(this)
        },

        /**
         * m a ~> (a -> m b) -> m b
         */
        chain(f) {
            return Effect(() => f(this.unsafeRun()).unsafeRun())
        },

        /**
         * m a ~> (a -> b) -> mb
         */
        map(f) {
            return this.chain((a) => Effect.of(f(a)))
        }
    }
}

/**
 * a -> m a
 */
Effect.of = (x) => Effect(() => x)

module.exports = Effect