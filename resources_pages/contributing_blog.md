---
layout: page
title: Contributing to the MDS Blog
---

Want to share your insights with the MDS community? Contributing to the [MDS blog](https://ubc-mds.github.io/) is easy and fun! Just follow these steps to get your blog post published with the help of our Editor, Varada Kolhatkar (`@kvarada`):


### 1. Reach Out

First things first—get in touch with the Editor to discuss your blog idea and how you'd like to contribute. We're excited to hear what you have in mind!

### 2. Fork the Repository

Head over to [the repo that houses this site](https://github.com/ubc-mds/ubc-mds.github.io) and fork it to your GitHub account. This will be your workspace.

### 3. Create a Branch

In your forked repo, create a new branch specifically for your blog post. This keeps everything neat and organized.

### 4. Write Your Blog Post

Now, the fun part! Write your blog post in Markdown format (`.md`). You can check out existing posts for inspiration.

- Place your `.md` file in the `_posts` folder of your branch.
- Make sure to include the following configuration at the top of your file:

```
---
layout: post
title: {Title of the Post}
subtitle: by {Author of the Post}
share-img: "link-of-an-image"
---
```

- The fourth line `share-img` is optional, but it's best to include one for future social media sharing. Here is an [example](https://raw.githubusercontent.com/UBC-MDS/UBC-MDS.github.io/master/_posts/2019-08-22-project-courses.md).
- Consider adding a line break after each line of text. This will allow the diffs to show up much better while the post is being edited.
- Don’t forget to add a byline at the end of your post with your name and a short bio:

```
## Authors:
[Author Name](link-to-your-bio) is {brief description of yourself}
```

- If you include images in your post, create a new folder under `img/blog` (give it a proper name) and place your images there.

### 5. Submit a Pull Request

Once your masterpiece is ready, submit a pull request from your branch to the [blog repo](https://github.com/UBC-MDS/UBC-MDS.github.io).

- Important: Double-check that you're sending the PR to the correct repo. We’ve had contributors accidentally send it to the [parent repo](https://github.com/daattali/beautiful-jekyll)—let’s avoid that!

### 6. Let Us Know

Give us a heads-up once your PR is submitted, and we'll review it. If all looks good, we’ll merge it.

### 7. Celebrate!

And just like that—Tada! Your blog post is live on our website for the world to see. 🎉
