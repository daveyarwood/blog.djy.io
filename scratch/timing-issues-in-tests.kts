import java.util.concurrent.LinkedBlockingQueue
import kotlin.concurrent.thread

typealias Test = () -> Boolean

fun fail(msg : String) {
  println("FAIL: ${msg}")
}

fun retryUntilTrue(intervalMs : Long, timeoutMs : Long, test : Test) : Boolean {
  val deadline = System.currentTimeMillis() + timeoutMs

  while (System.currentTimeMillis() < deadline) {
    if (test()) {
      return true
    }

    Thread.sleep(intervalMs)
  }

  return false
}

fun assertEventuallyTrue(
  intervalMs : Long, timeoutMs : Long, failureMsg : String, test : Test
) {
  if (!retryUntilTrue(intervalMs, timeoutMs, test)) {
    fail(failureMsg);
  }
}

fun assertNeverTrue(
  intervalMs : Long, timeoutMs : Long, failureMsg : String, test : Test
) {
  if (retryUntilTrue(intervalMs, timeoutMs, test)) {
    fail(failureMsg);
  }
}

// assertEventuallyTrue(100, 1000, "nope", { false })

val iceCreamVotes = mutableMapOf<String, Int>()
val queue = LinkedBlockingQueue<String>()

// worker process
thread {
  while (true) {
    val flavor = queue.take()
    val currentCount = iceCreamVotes.getOrElse(flavor) { 0 }
    iceCreamVotes[flavor] = currentCount + 1
  }
}

queue.put("chocolate")
// Thread.sleep(500)

println(iceCreamVotes)

fun voteCountedForRockyRoad() : Boolean {
  queue.put("rocky road")
  // Give the worker a little time to update the tally.
  Thread.sleep(5000)

  // Surely by now it's updated?
  val votesForRockyRoad = iceCreamVotes.getOrElse("rocky road") { 0 }
  return votesForRockyRoad > 0
}

