# Architecture

The Brand Governance Styleguide has two layers:

1. **Source layer**
   - static HTML route pages
   - one shared CSS token and component system
   - no runtime dependency on a JavaScript framework

2. **Delivery layer**
   - build script copies source into a Pages-ready `site/` directory
   - `robots.txt`, `sitemap.xml`, and `CNAME` are generated during build
   - screenshot automation produces README proof assets from the built site

## Purpose

This repo is intentionally CSS-first. The governance value is not hidden behind application code; the styling system itself is part of the public proof.

